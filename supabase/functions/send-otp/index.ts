import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/**
 * Normalizes and validates an Indian mobile number.
 * Returns { digits10: "9876543210", e164: "+919876543210", textlocalNumber: "919876543210" }
 */
function normalizeIndianPhone(input: string): { digits10: string; e164: string; textlocalNumber: string } | null {
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

  return {
    digits10: digits,
    e164: `+91${digits}`,
    textlocalNumber: `91${digits}`,
  };
}

/**
 * Generates a cryptographically secure 6-digit OTP string.
 */
function generateSecureOtp(): string {
  const randomBuffer = new Uint32Array(1);
  crypto.getRandomValues(randomBuffer);
  // Guarantee 6-digit range [100000, 999999]
  const otpNumber = 100000 + (randomBuffer[0] % 900000);
  return otpNumber.toString();
}

/**
 * Hashes an OTP with a random salt using SHA-256.
 */
async function hashOtp(otp: string, salt: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(`${salt}:${otp}`);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

serve(async (req: Request) => {
  // 1. Handle CORS Preflight
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

    if (!rawPhone) {
      return new Response(
        JSON.stringify({ success: false, error: "Phone number is required." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Validate and Normalize Indian Phone Number
    const phoneData = normalizeIndianPhone(rawPhone);
    if (!phoneData) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Invalid Indian mobile number. Must be a valid 10-digit number starting with 6, 7, 8, or 9.",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 3. Supabase Admin Client using Service Role
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error("[send-otp] Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
      return new Response(
        JSON.stringify({ success: false, error: "Server configuration error." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // 4. Rate Limiting & Cooldown Protection
    const now = new Date();
    const oneMinuteAgo = new Date(now.getTime() - 60 * 1000).toISOString();
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000).toISOString();

    // Check 60-second cooldown
    const { data: recentOtps, error: cooldownError } = await supabaseAdmin
      .from("otp_verifications")
      .select("id, created_at")
      .eq("phone", phoneData.e164)
      .gt("created_at", oneMinuteAgo)
      .order("created_at", { ascending: false })
      .limit(1);

    if (cooldownError) {
      console.error("[send-otp] Database cooldown check error:", cooldownError);
    }

    if (recentOtps && recentOtps.length > 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Please wait 60 seconds before requesting another verification code.",
          cooldownRemaining: 60,
        }),
        { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check hourly limit (maximum 5 OTPs per hour per phone)
    const { count: hourlyCount, error: hourlyError } = await supabaseAdmin
      .from("otp_verifications")
      .select("id", { count: "exact", head: true })
      .eq("phone", phoneData.e164)
      .gt("created_at", oneHourAgo);

    if (hourlyError) {
      console.error("[send-otp] Database hourly count error:", hourlyError);
    }

    if (hourlyCount && hourlyCount >= 5) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Too many OTP attempts for this number. For security, please try again in an hour.",
        }),
        { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 5. Generate Secure OTP & Hash
    const otp = generateSecureOtp();
    const salt = crypto.randomUUID();
    const otpHash = await hashOtp(otp, salt);
    const expiresAt = new Date(now.getTime() + 10 * 60 * 1000).toISOString(); // 10 minutes expiry

    // 6. Check Textlocal Configuration Secrets
    const textlocalApiKey = Deno.env.get("TEXTLOCAL_API_KEY");
    const textlocalSender = Deno.env.get("TEXTLOCAL_SENDER") || "TXTLCL";
    const textlocalTemplate =
      Deno.env.get("TEXTLOCAL_TEMPLATE") ||
      "Your VetCare verification code is %s. Valid for 10 minutes. Do not share this OTP with anyone.";

    if (!textlocalApiKey) {
      console.error("[send-otp] TEXTLOCAL_API_KEY secret is not set in Supabase Edge Functions.");
      return new Response(
        JSON.stringify({
          success: false,
          error: "SMS provider is not configured. TEXTLOCAL_API_KEY secret must be added to Supabase Edge Function secrets.",
        }),
        { status: 503, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Format message replacing placeholder with the OTP
    const message = textlocalTemplate.includes("%s")
      ? textlocalTemplate.replace("%s", otp)
      : `${textlocalTemplate} ${otp}`;

    // 7. Dispatch SMS via Official Textlocal India API (https://api.textlocal.in/send/)
    const textlocalParams = new URLSearchParams();
    textlocalParams.append("apikey", textlocalApiKey);
    textlocalParams.append("numbers", phoneData.textlocalNumber);
    textlocalParams.append("message", message);
    textlocalParams.append("sender", textlocalSender);

    const textlocalResponse = await fetch("https://api.textlocal.in/send/", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: textlocalParams.toString(),
    });

    const textlocalResult = await textlocalResponse.json().catch(() => null);

    if (!textlocalResult || textlocalResult.status !== "success") {
      const errorMsg =
        textlocalResult?.errors?.[0]?.message ||
        textlocalResult?.warnings?.[0]?.message ||
        "Failed to deliver SMS through Textlocal.";
      console.error("[send-otp] Textlocal API Error:", errorMsg);

      return new Response(
        JSON.stringify({
          success: false,
          error: `SMS delivery failed: ${errorMsg}`,
        }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 8. Store Only Hashed OTP Record in Database (Never plaintext OTP)
    const { error: insertError } = await supabaseAdmin.from("otp_verifications").insert({
      phone: phoneData.e164,
      otp_hash: otpHash,
      salt: salt,
      attempts: 0,
      max_attempts: 5,
      is_verified: false,
      expires_at: expiresAt,
    });

    if (insertError) {
      console.error("[send-otp] Failed to store OTP record:", insertError);
      return new Response(
        JSON.stringify({ success: false, error: "Database error storing verification record." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: "OTP sent successfully to your mobile number.",
        cooldownSeconds: 60,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    console.error("[send-otp] Unexpected error:", err);
    return new Response(
      JSON.stringify({ success: false, error: "An unexpected server error occurred." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
