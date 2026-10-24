# VetCare Medical - Premium Pet Care Application (Step 1)

A Flutter & Supabase powered veterinary healthcare mobile application engineered for Android and iOS.

---

## 🎨 Design System

| Element | Hex Code | Purpose |
|---|---|---|
| **Primary Green** | `#174A3A` | Brand identity, primary buttons, headers, app bars |
| **Light Sage** | `#E7F1E8` | Card tints, pill badges, selected states |
| **Background** | `#F6F3EA` | Warm canvas background across all screens |
| **Accent Gold** | `#F4B860` | High-priority CTAs, urgency badges, highlights |
| **White** | `#FFFFFF` | Card surfaces, inputs, modal dialogs |
| **Text Primary** | `#202923` | High-contrast typography |

---

## 📱 Implemented Screens (Step 1)

1. **Screen 1 — Splash Screen (`/splash`)**:
   - Custom animated veterinary branding (medical cross & paw emblem).
   - Real-time Supabase auth session check.
   - Intelligent routing based on session validity & profile completion status.
2. **Screen 2 — Mobile Login (`/login`)**:
   - High-quality responsive pet care illustration card.
   - Mobile number input with locked `+91` Indian country code and flag badge.
   - Validates 10-digit Indian numbers starting with `6`, `7`, `8`, or `9`.
   - Dynamic loading and inline error states.
   - Interactive Terms of Service & Privacy Policy bottom sheets.
3. **Screen 3 — OTP Verification (`/otp`)**:
   - 6-digit individual PIN input boxes with auto-focus movement, backspace jump, and full-clipboard paste support.
   - 30-second cooldown timer for "Resend Code" to protect SMS budgets.
   - "Wrong number? Edit phone number" inline action.
   - Explicit error display if SMS provider is unconfigured or OTP is invalid/expired.
   - Real Supabase Phone OTP authentication (`signInWithOtp` & `verifyOTP`).
4. **Screen 4 — Profile Setup (`/profile-setup`)**:
   - Shown exclusively for first-time users.
   - Full Name (required, min 2 chars) and Email Address (optional, format validated).
   - Displays verified phone number.
   - Inserts/updates profile row in Supabase PostgreSQL `profiles` table.
5. **Screen 5 — Home Screen (`/home`)**:
   - Personalized user greeting: `"Good morning, [Name] 👋"`.
   - Notification button with unread badge.
   - Premium 24/7 veterinary healthcare emergency hero banner with `"Book Vet Appointment"` CTA.
   - 4 Service Categories: Vet Consultation, Vaccination, Grooming, Pet Pharmacy (with clear Step 2 placeholders).
   - "My Pets" preview carousel with active pet health cards and `+ Add Pet` action.
   - "Upcoming Appointment" preview card with doctor details, clinic location, and confirmed status.
   - Bottom navigation bar: **Home**, **Appointments**, **Pharmacy**, and **Profile**.
   - Profile tab includes account details and a **Sign Out** button that clears the session and returns to login.

---

## 🗄️ Supabase Configuration & SQL Migrations

### 1. Execute SQL Migration
Run the SQL script located at:
```
supabase/migrations/01_create_profiles.sql
```
In your **Supabase Dashboard -> SQL Editor**, paste and execute the migration.

This script sets up:
1. `public.profiles` table linked via foreign key to `auth.users(id) ON DELETE CASCADE`.
2. Row Level Security (RLS) policies:
   - `SELECT`: Only the authenticated user can view their row (`auth.uid() = id`).
   - `INSERT`: Only the authenticated user can insert their row (`auth.uid() = id`).
   - `UPDATE`: Only the authenticated user can update their row (`auth.uid() = id`).
3. An automatic trigger `handle_new_user()` on `auth.users` that provisions the profile row upon SMS verification.
4. An automatic trigger `handle_updated_at()` that updates timestamps on edits.

### 2. Configure Phone Auth & SMS Provider in Supabase
In your Supabase project:
1. Go to **Authentication -> Providers -> Phone**.
2. Toggle **Enable Phone Provider** ON.
3. Choose an SMS Provider:
   - **Twilio**: Requires Account SID, Auth Token, and Message Service SID / Twilio Phone Number.
   - **MessageBird**, **Vonage**, or **Twilio Verify**: Also supported.
4. **SMS Gateway Costs & Indian DLT Requirements**:
   - In India, TRAI mandates **DLT (Distributed Ledger Technology)** registration for transactional SMS.
   - If using Twilio in India, register your Principal Entity (PE) and Header / Sender ID (e.g. `VETMED`) with an Indian Telecom DLT portal (e.g. Vilpower, Airtel DLT, Jio DLT).
   - SMS cost per OTP in India typically ranges from ₹0.12 to ₹0.25 ($0.0015 - $0.003 USD) on Twilio/local gateways.
   - For sandbox testing, Supabase allows adding test phone numbers and fixed OTP codes under **Authentication -> Phone -> Test phone numbers**.

### 3. Configure Local Credentials
Copy `.env.example` to `.env` in the root folder:
```bash
cp .env.example .env
```
Update `.env` with your project keys:
```env
SUPABASE_URL=https://[YOUR_PROJECT_ID].supabase.co
SUPABASE_ANON_KEY=[YOUR_ANON_PUBLIC_KEY]
```
*(Never expose the `service_role` secret key in Flutter client apps).*

---

## 🚀 Running the App

### 1. Run Flutter Analyze
```bash
flutter analyze
```

### 2. Run All Tests
```bash
flutter test
```

### 3. Launch on Android / iOS / Web / Desktop
```bash
# Using .env file
flutter run

# Or passing credentials via compile flags
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

---

## 🧪 Verification & Test Suite

The test suite in `test/auth_and_navigation_test.dart` and `test/widget_test.dart` covers all 10 required test scenarios:
1. ✅ **Invalid phone number**: Empty, < 10 digits, or invalid Indian prefixes (1-5) are rejected.
2. ✅ **OTP request**: Valid 10-digit Indian phone triggers `signInWithOtp` with `+91` E.164 formatting and initiates cooldown.
3. ✅ **Wrong OTP**: Invalid code triggers proper error banner.
4. ✅ **Expired OTP**: Expired token is detected and user is guided to request a fresh code.
5. ✅ **Correct OTP**: 6-digit verification establishes authenticated Supabase session.
6. ✅ **New user profile setup**: Enforces minimum 2-character full name, optional email, and commits to database.
7. ✅ **Existing user login**: Returning user with existing profile skips setup and goes directly to Home.
8. ✅ **Session persistence**: Cold app launch restores existing valid session.
9. ✅ **Logout**: Sign out clears local credentials and resets router to Login.
10. ✅ **Unauthorized access to Home**: Direct navigation to `/home` without session is blocked and routed to `/login`.
