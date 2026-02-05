# Run Flutter app in Chrome with environment variables
# Usage: .\run_web.ps1

# Read environment variables from .env file
$envContent = Get-Content .env -Raw
$supabaseUrl = ($envContent | Select-String 'SUPABASE_URL=(.*)').Matches.Groups[1].Value
$supabaseAnonKey = ($envContent | Select-String 'SUPABASE_ANON_KEY=(.*)').Matches.Groups[1].Value

Write-Host "Starting Flutter web app..." -ForegroundColor Green
Write-Host "Supabase URL: $supabaseUrl" -ForegroundColor Cyan

flutter run -d chrome --dart-define=SUPABASE_URL=$supabaseUrl --dart-define=SUPABASE_ANON_KEY=$supabaseAnonKey
