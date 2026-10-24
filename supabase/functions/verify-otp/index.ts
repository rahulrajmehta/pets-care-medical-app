import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/**
 * Normalizes an Indian mobile number.
 */
function normalizeIndianPhone(input: string): string | null {
  if (!input || typeof input !== "string") return null;
  let digits = input.replace(/\D/g, "");

  if (digits.startsWith("91") && digits.length === 12) {
    digits = digits.substring(2);
  } else if (digits.startsWith("0") && digits.length === 11) {
    digits = digits.substring(1);
  }

  if (digits.length !== 10) return null;
  const firstDigit = digits.charAt(0);
  if (!["6", "7", "8", "9"].includes(firstDigit)) return null;

  return `+91${digits}`;
}

/**
 * Computes SHA-256 hash of salt + OTP.
 */
async function hashOtp(otp: string, salt: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(`${salt}:${otp}`);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

serve(async (req: Request) => {
  // 1. CORS Preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ success: false, error: "Method not allowed. Use POST." }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  try {
    const body = await req.json().catch(() => ({}));
    const rawPhone = body.phone;
    const submittedOtp = body.otp ? String(body.otp).trim() : "";

    if (!rawPhone || !submittedOtp) {
      return new Response(
        JSON.stringify({ success: false, error: "Phone number and OTP are required." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Validate OTP format (must be exactly 6 digits)
    if (!/^\d{6}$/.test(submittedOtp)) {
      return new Response(
        JSON.stringify({ success: false, error: "OTP must be exactly 6 digits." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const normalizedPhone = normalizeIndianPhone(rawPhone);
    if (!normalizedPhone) {
      return new Response(
        JSON.stringify({ success: false, error: "Invalid mobile number format." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 3. Supabase Admin Client using Service Role
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error("[verify-otp] Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
      return new Response(
        JSON.stringify({ success: false, error: "Server configuration error." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // 4. Retrieve Latest Active Unverified OTP for this phone
    const { data: records, error: fetchError } = await supabaseAdmin
      .from("otp_verifications")
      .select("*")
      .eq("phone", normalizedPhone)
      .eq("is_verified", false)
      .order("created_at", { ascending: false })
      .limit(1);

    if (fetchError || !records || records.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "No active OTP request found for this phone. Please request a new code.",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const record = records[0];
    const now = new Date();
    const expiresAt = new Date(record.expires_at);

    // 5. Check Expiration
    if (now > expiresAt) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "The OTP code has expired. Please request a new verification code.",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 6. Check Attempt Limits (Abuse Protection)
    if (record.attempts >= record.max_attempts) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Maximum verification attempts exceeded. For security, this OTP has been invalidated.",
        }),
        { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 7. Verify Submitted OTP against stored Hash
    const calculatedHash = await hashOtp(submittedOtp, record.salt);
    const isMatch = calculatedHash === record.otp_hash;

    if (!isMatch) {
      const newAttempts = record.attempts + 1;
      await supabaseAdmin
        .from("otp_verifications")
        .update({ attempts: newAttempts })
        .eq("id", record.id);

      const remaining = record.max_attempts - newAttempts;
      return new Response(
        JSON.stringify({
          success: false,
          error: remaining > 0
            ? `Incorrect OTP. You have ${remaining} attempt(s) remaining.`
            : "Maximum verification attempts exceeded. Please request a new code.",
          remainingAttempts: Math.max(0, remaining),
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 8. Invalidate OTP (Mark as Verified to prevent reuse)
    await supabaseAdmin
      .from("otp_verifications")
      .update({
        is_verified: true,
        verified_at: now.toISOString(),
      })
      .eq("id", record.id);

    // 9. Legitimate Supabase Auth Session Provisioning
    // Check if user exists in auth.users by phone
    const { data: userList, error: listError } = await supabaseAdmin.auth.admin.listUsers();
    let authUser = userList?.users?.find((u) => u.phone === normalizedPhone);

    if (!authUser) {
      // Create user with confirmed phone
      const { data: newUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
        phone: normalizedPhone,
        phone_confirm: true,
      });

      if (createError || !newUser?.user) {
        console.error("[verify-otp] Failed to create auth user:", createError);
        return new Response(
          JSON.stringify({ success: false, error: "Failed to provision user profile." }),
          { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      authUser = newUser.user;
    }

    // Generate a single-use session ticket to exchange for a legitimate Supabase session
    const oneTimeTicket = crypto.randomUUID();
    await supabaseAdmin.auth.admin.updateUserById(authUser.id, {
      password: oneTimeTicket,
    });

    // Fetch user profile from public.profiles
    const { data: profile } = await supabaseAdmin
      .from("profiles")
      .select("*")
      .eq("id", authUser.id)
      .maybeSingle();

    return new Response(
      JSON.stringify({
        success: true,
        message: "OTP verified successfully.",
        userId: authUser.id,
        phone: normalizedPhone,
        isProfileCompleted: profile?.is_profile_completed ?? false,
        sessionTicket: oneTimeTicket,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    console.error("[verify-otp] Unexpected error:", err);
    return new Response(
      JSON.stringify({ success: false, error: "An unexpected server error occurred." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
