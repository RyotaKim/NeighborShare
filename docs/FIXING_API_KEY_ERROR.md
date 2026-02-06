# 🔑 Fixing "Invalid API Key" Error

## Problem
You're getting a 401 Unauthorized error with "Invalid API key" when trying to sign up.

## Root Cause
The `SUPABASE_ANON_KEY` in your `.env` file is **NOT** a valid Supabase anon key.

**Current invalid key:** `sb_publishable_2xZWGQ6sul0lXqIXa25RXg_73KlOxjm`

This looks like a Stripe publishable key format, not a Supabase JWT token.

---

## ✅ How to Fix

### Step 1: Get Your Correct Anon Key from Supabase

1. **Go to your Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/iyballqoxboxmqytyhrc/settings/api
   ```

2. **Find the "Project API keys" section**

3. **Copy the "anon" "public" key** - It should look like this:
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml5YmFsbHFveGJveG1xeXR5aHJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg0MTEyMDQsImV4cCI6MjA1Mzk4NzIwNH0.ACTUAL_SIGNATURE_HERE
   ```
   
   ✅ **Correct format:** Starts with `eyJ`, has **exactly 3 parts** separated by dots (`.`), very long string
   
   ❌ **Wrong format:** Starts with `sb_`, contains words like "publishable", short string

---

### Step 2: Update Your .env File

1. **Open:** `.env` file in your project root

2. **Replace the line:**
   ```bash
   # OLD (WRONG):
   SUPABASE_ANON_KEY=YOUR_ANON_KEY_FROM_SUPABASE_DASHBOARD_HERE
   
   # NEW (paste your actual key from Supabase):
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3M...your_actual_key_here
   ```

3. **Save the file**

---

### Step 3: Restart Your App

For **Web** (Chrome):
```bash
# Stop the current app (Ctrl+C in terminal)
# Then restart:
flutter run -d chrome
```

For **Mobile** (Android/iOS):
```bash
# Hot restart won't reload .env changes
# Stop and restart:
flutter run
```

---

## 📝 Notes

- **Never commit `.env` to git!** It's already in `.gitignore`
- **The anon key is public** - it's safe to use in your app (has limited permissions)
- **Each Supabase project** has a unique anon key
- **If you reset your keys** in Supabase, you'll need to update `.env` again

---

## 🐛 Still Having Issues?

### Check Supabase Dashboard:

1. **Authentication > Providers > Email**
   - ✅ "Enable email provider" should be **ON**
   
2. **Authentication > Settings**
   - ✅ "Enable email signups" should be **ON**

3. **SQL Editor** - Run this to verify your database is set up:
   ```sql
   SELECT * FROM profiles LIMIT 1;
   ```
   If it says "relation does not exist", you need to run the database setup script from `docs/DATABASE_SCHEMA.md`

---

## ✅ Success!

Once you've updated the `.env` file with the correct anon key and restarted the app, registration should work! You'll be able to:

1. ✅ Sign up with email/username/password
2. ✅ See the email verification screen
3. ✅ Check your email for verification link
4. ✅ Log in after verification

---

**Last Updated:** February 6, 2026
