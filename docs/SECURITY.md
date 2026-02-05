# Security Implementation - NeighborShare

## Overview
Comprehensive security measures including authentication, authorization, data protection, and privacy features.

---

## Authentication System

<details>
<summary><b>JWT Token Management</b></summary>

### How JWT Works in NeighborShare

**Token Generation (Handled by Supabase):**
1. User signs in with email/password
2. Supabase verifies credentials
3. Generates JWT access token (expires in 1 hour)
4. Generates refresh token (expires in 30 days)
5. Returns both tokens to client

### Token Structure
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "v1.MRjVsFgD7HoL...",
  "user": {
    "id": "uuid",
    "email": "user@example.com"
  }
}
```

### Token Storage (Flutter)
```dart
// Automatic storage in secure storage
// Supabase Flutter handles this internally
final session = supabase.auth.currentSession;
final accessToken = session?.accessToken;

// Token is persisted and auto-loaded on app restart
```

### Token Refresh (Automatic)
```dart
// Supabase automatically refreshes token before expiration
// No manual refresh needed
// Client receives new access token seamlessly

// Listen to auth state changes
supabase.auth.onAuthStateChange.listen((event) {
  if (event.event == AuthChangeEvent.tokenRefreshed) {
    print('Token refreshed');
  }
});
```

### Token Revocation
```dart
// Sign out revokes all tokens
await supabase.auth.signOut();

// Optionally: Force logout from all devices
// (requires custom backend logic)
```

</details>

<details>
<summary><b>Password Security</b></summary>

### Password Requirements
- **Minimum length**: 8 characters
- **Must contain**: Letters and numbers (recommended)
- **Maximum length**: 72 characters (bcrypt limit)
- **Not allowed**: Common passwords ("password123", "12345678")

### Password Validation (Client-Side)
```dart
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
    return 'Password must contain letters and numbers';
  }
  return null;
}
```

### Password Strength Indicator
```dart
enum PasswordStrength { weak, medium, strong }

PasswordStrength checkPasswordStrength(String password) {
  int score = 0;
  
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[a-z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
  
  if (score <= 2) return PasswordStrength.weak;
  if (score <= 4) return PasswordStrength.medium;
  return PasswordStrength.strong;
}
```

### Password Hashing (Server-Side)
- Handled automatically by Supabase
- Uses **bcrypt** with salt
- Hash never exposed to client
- Password never stored in plain text

### Password Reset Flow
```dart
// 1. User requests reset
await supabase.auth.resetPasswordForEmail(
  email,
  redirectTo: 'myapp://reset-password',
);

// 2. User receives email with magic link
// 3. Link opens app with token
// 4. User enters new password
await supabase.auth.updateUser(
  UserAttributes(password: newPassword),
);
```

</details>

<details>
<summary><b>Session Management</b></summary>

### Session Lifecycle
```dart
// Check if user is logged in
final session = supabase.auth.currentSession;
final isLoggedIn = session != null;

// Get current user
final user = supabase.auth.currentUser;

// Session automatically persists across app restarts
// Token is stored in secure storage (iOS Keychain / Android Keystore)
```

### Session Expiration
- **Access token**: 1 hour (default)
- **Refresh token**: 30 days (default)
- **Automatic refresh**: Yes, handled by SDK
- **Inactivity timeout**: Can be configured (e.g., 7 days)

### Force Logout
```dart
// Logout from current device
await supabase.auth.signOut();

// Logout from all devices (future enhancement)
// Requires tracking active sessions in database
await supabase.rpc('revoke_all_sessions', params: {'user_id': userId});
```

### Concurrent Sessions
- **Allowed**: Yes, multiple devices supported
- **Tracking**: Can track active sessions with custom table
- **Management**: Future feature to view/revoke device sessions

</details>

---

## Row Level Security (RLS)

<details>
<summary><b>What is RLS?</b></summary>

Row Level Security (RLS) is a PostgreSQL feature that restricts which rows can be accessed or modified based on the current user.

### Why RLS is Critical
- Enforces security at database level
- Prevents unauthorized access even if client is compromised
- Cannot be bypassed by modifying API requests
- Acts as final security layer

### How RLS Works with Supabase Auth
```sql
-- Example: Users can only update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  USING (auth.uid() = id);
```

**auth.uid()** returns the ID of the currently authenticated user from their JWT token.

</details>

<details>
<summary><b>RLS Policies by Table</b></summary>

### Profiles Table

**SELECT** (Read):
```sql
-- Anyone can view all profiles (for displaying item owners)
CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);
```

**INSERT** (Create):
```sql
-- Users can only create their own profile
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
```

**UPDATE** (Modify):
```sql
-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);
```

**DELETE** (Remove):
```sql
-- Users can delete their own profile (cascades to items, messages)
CREATE POLICY "Users can delete own profile"
  ON profiles FOR DELETE
  USING (auth.uid() = id);
```

---

### Items Table

**SELECT** (Read):
```sql
-- Everyone can view all items
CREATE POLICY "Items are viewable by everyone"
  ON items FOR SELECT
  USING (true);
```

**INSERT** (Create):
```sql
-- Only authenticated users can create items
-- Must set themselves as owner
CREATE POLICY "Authenticated users can create items"
  ON items FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

**UPDATE** (Modify):
```sql
-- Users can only update their own items
CREATE POLICY "Users can update own items"
  ON items FOR UPDATE
  USING (auth.uid() = user_id);
```

**DELETE** (Remove):
```sql
-- Users can only delete their own items
CREATE POLICY "Users can delete own items"
  ON items FOR DELETE
  USING (auth.uid() = user_id);
```

---

### Conversations Table

**SELECT** (Read):
```sql
-- Users can only see conversations they're part of
CREATE POLICY "Users can view own conversations"
  ON conversations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = id
      AND user_id = auth.uid()
    )
  );
```

**INSERT** (Create):
```sql
-- Any authenticated user can create conversations
CREATE POLICY "Users can create conversations"
  ON conversations FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');
```

---

### Messages Table

**SELECT** (Read):
```sql
-- Users can only read messages in their conversations
CREATE POLICY "Users can view messages in their conversations"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = messages.conversation_id
      AND user_id = auth.uid()
    )
  );
```

**INSERT** (Create):
```sql
-- Users can only send messages to their own conversations
-- Must be sender and participant
CREATE POLICY "Users can send messages to their conversations"
  ON messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = messages.conversation_id
      AND user_id = auth.uid()
    )
  );
```

</details>

<details>
<summary><b>Testing RLS Policies</b></summary>

### Verify RLS is Enabled
```sql
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';
-- rowsecurity should be true for all tables
```

### Test Policy as Specific User
```sql
-- Set role to test user
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims TO '{"sub":"user-uuid-here"}';

-- Try to access data
SELECT * FROM items WHERE user_id != 'user-uuid-here';
-- Should return 0 rows (or error if INSERT/UPDATE/DELETE)
```

### Common RLS Issues
- **Forgot to enable RLS**: Table is completely open
- **Policy too restrictive**: Users can't access their own data
- **Policy too permissive**: Users can access others' data
- **Performance**: Complex policies can slow queries (add indexes)

</details>

---

## Data Validation

<details>
<summary><b>Client-Side Validation (Flutter)</b></summary>

### Form Validation
```dart
// Email validation
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}

// Username validation
String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Username is required';
  }
  if (value.length < 3) {
    return 'Username must be at least 3 characters';
  }
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
    return 'Username can only contain letters, numbers, and underscores';
  }
  return null;
}

// Item title validation
String? validateTitle(String? value) {
  if (value == null || value.isEmpty) {
    return 'Title is required';
  }
  if (value.length < 3) {
    return 'Title must be at least 3 characters';
  }
  if (value.length > 60) {
    return 'Title is too long (max 60 characters)';
  }
  return null;
}
```

### Image Validation
```dart
Future<bool> validateImage(File image) async {
  // Check file size
  final size = await image.length();
  if (size > 5 * 1024 * 1024) {
    throw Exception('Image must be less than 5MB');
  }
  
  // Check file type
  final mimeType = lookupMimeType(image.path);
  if (mimeType == null || !['image/jpeg', 'image/png', 'image/webp'].contains(mimeType)) {
    throw Exception('Only JPG, PNG, and WebP images are allowed');
  }
  
  return true;
}
```

### Input Sanitization
```dart
String sanitizeInput(String input) {
  // Remove leading/trailing whitespace
  input = input.trim();
  
  // Remove multiple consecutive spaces
  input = input.replaceAll(RegExp(r'\s+'), ' ');
  
  // Remove potentially dangerous characters for display
  // (Backend should also sanitize before storage)
  input = input.replaceAll(RegExp(r'[<>]'), '');
  
  return input;
}
```

</details>

<details>
<summary><b>Server-Side Validation (Database)</b></summary>

### Database Constraints

**NOT NULL** - Required fields:
```sql
CREATE TABLE items (
  title TEXT NOT NULL,
  user_id UUID NOT NULL,
  category TEXT NOT NULL
);
```

**CHECK** - Value validation:
```sql
-- Username length
CONSTRAINT username_length CHECK (char_length(username) >= 3)

-- Title length
CONSTRAINT title_length CHECK (char_length(title) >= 3)

-- Category enum
CONSTRAINT valid_category CHECK (
  category IN ('Tools', 'Kitchen', 'Outdoor', 'Games')
)

-- Status enum
CONSTRAINT valid_status CHECK (
  status IN ('Available', 'On Loan')
)

-- Message not empty
CONSTRAINT content_not_empty CHECK (char_length(trim(content)) > 0)
```

**UNIQUE** - Prevent duplicates:
```sql
username TEXT UNIQUE NOT NULL
```

**REFERENCES** (Foreign Keys):
```sql
user_id UUID REFERENCES profiles(id) ON DELETE CASCADE
```

### Validation Functions (Future)
```sql
-- Check profanity in item descriptions
CREATE OR REPLACE FUNCTION contains_profanity(text TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  -- Check against profanity list
  RETURN text ~* '(badword1|badword2|badword3)';
END;
$$ LANGUAGE plpgsql;

-- Enforce in constraint
ALTER TABLE items ADD CONSTRAINT no_profanity
  CHECK (NOT contains_profanity(description));
```

</details>

---

## Storage Security

<details>
<summary><b>Storage Bucket Policies</b></summary>

### Item Images Bucket

**Public Read Access:**
```sql
-- Anyone can view images
CREATE POLICY "Item images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'item-images');
```

**Authenticated Upload:**
```sql
-- Only logged-in users can upload
CREATE POLICY "Authenticated users can upload item images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'item-images' AND
    auth.role() = 'authenticated'
  );
```

**Owner-Only Update:**
```sql
-- Users can only modify their own images
CREATE POLICY "Users can update own item images"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'item-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

**File Path Structure:**
```
item-images/
  {user_id}/
    {item_id}_full.jpg
    {item_id}_thumb.jpg
```

This ensures users can only access files in their own folder.

</details>

<details>
<summary><b>File Upload Security</b></summary>

### Client-Side Checks
```dart
Future<void> uploadItemImage(File image, String itemId) async {
  // 1. Validate file type
  final mimeType = lookupMimeType(image.path);
  if (!['image/jpeg', 'image/png'].contains(mimeType)) {
    throw Exception('Invalid file type');
  }
  
  // 2. Validate file size
  final size = await image.length();
  if (size > 5 * 1024 * 1024) {
    throw Exception('File too large');
  }
  
  // 3. Compress image
  final compressed = await ImageUtils.compressImage(image);
  
  // 4. Generate secure path
  final userId = supabase.auth.currentUser!.id;
  final path = '$userId/${itemId}_full.jpg';
  
  // 5. Upload with content type
  await supabase.storage.from('item-images').upload(
    path,
    compressed,
    fileOptions: FileOptions(
      contentType: 'image/jpeg',
      upsert: false, // Prevent overwriting existing
    ),
  );
}
```

### Server-Side Restrictions
```sql
-- Supabase Storage configuration
-- Set in dashboard: Storage > item-images > Settings

File size limit: 5MB
Allowed MIME types: image/jpeg, image/png, image/webp
Public: true (read-only)
```

### Virus Scanning (Future)
- Integrate with ClamAV or similar
- Scan files before allowing access
- Quarantine suspicious uploads

</details>

---

## Privacy Features

<details>
<summary><b>User Privacy Controls</b></summary>

### Profile Visibility
```dart
// Future: Add privacy settings to profiles table
class PrivacySettings {
  bool showFullName;       // Hide real name if false
  bool showNeighborhood;   // Hide location if false
  bool showItemStats;      // Hide lending history
  
  // Who can message me
  MessagePrivacy messagePrivacy; // Everyone, MutualBorrowers, Nobody
}
```

### Contact Information Protection
- **No phone numbers** stored or displayed in app
- **No email addresses** visible to other users
- **Communication only via in-app chat**
- Users can choose to share contact info privately in chat

### Location Privacy
- **No GPS coordinates** stored (only neighborhood text)
- **Approximate location only** ("Downtown", not exact address)
- **Pickup location** shared only after agreement in chat

</details>

<details>
<summary><b>Data Retention & Deletion</b></summary>

### User Data Deletion
```sql
-- When user deletes account
-- Cascade deletes handle related data

CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE items (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE
);

-- Results in:
-- 1. User deleted from auth.users
-- 2. Profile deleted (CASCADE)
-- 3. All items deleted (CASCADE)
-- 4. All messages deleted (CASCADE)
-- 5. All storage files deleted (needs manual cleanup)
```

### Right to be Forgotten (GDPR)
```dart
// Delete account function
Future<void> deleteAccount() async {
  final userId = supabase.auth.currentUser!.id;
  
  // 1. Delete all storage files
  final items = await supabase
    .from('items')
    .select('image_url')
    .eq('user_id', userId);
  
  for (final item in items) {
    await deleteImageFromUrl(item['image_url']);
  }
  
  // 2. Delete user account (cascades to all tables)
  await supabase.auth.admin.deleteUser(userId);
  
  // 3. Sign out
  await supabase.auth.signOut();
}
```

### Message Retention
- **Keep forever**: Default (needed for conversation context)
- **User can delete**: Own messages only (marks as "[Deleted]")
- **Conversation deletion**: Both parties must delete to remove from DB

</details>

<details>
<summary><b>Safety Features (Future)</b></summary>

### Block User
```dart
// Add blocked_users table
CREATE TABLE blocked_users (
  blocker_id UUID REFERENCES profiles(id),
  blocked_id UUID REFERENCES profiles(id),
  blocked_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (blocker_id, blocked_id)
);

// Prevent blocked users from seeing your items
CREATE POLICY "Blocked users cannot see items"
  ON items FOR SELECT
  USING (
    NOT EXISTS (
      SELECT 1 FROM blocked_users
      WHERE blocked_id = auth.uid()
      AND blocker_id = user_id
    )
  );
```

### Report User/Item
```sql
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES profiles(id),
  reported_user_id UUID REFERENCES profiles(id),
  reported_item_id UUID REFERENCES items(id),
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'pending', -- pending, reviewed, resolved
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Content Moderation
- **Automated**: Filter profanity in titles/descriptions
- **Manual**: Review flagged content
- **Actions**: Warning, temporary ban, permanent ban

</details>

---

## API Security

<details>
<summary><b>Rate Limiting (Future)</b></summary>

### Prevent Abuse
```sql
-- Supabase Edge Functions or middleware
-- Limit requests per user per minute

-- Example limits:
-- Auth endpoints: 5 requests/minute
-- Item creation: 10 requests/hour
-- Messages: 60 requests/minute
```

### Implementation
```typescript
// Edge Function example
export async function handler(req: Request) {
  const userId = req.headers.get('user-id');
  
  // Check rate limit from Redis/database
  const requestCount = await getRateLimit(userId);
  
  if (requestCount > LIMIT) {
    return new Response('Rate limit exceeded', { status: 429 });
  }
  
  // Increment counter
  await incrementRateLimit(userId);
  
  // Process request
  // ...
}
```

</details>

<details>
<summary><b>HTTPS Only</b></summary>

- All API requests use **HTTPS** (TLS 1.2+)
- Supabase endpoints enforce HTTPS
- No sensitive data transmitted over HTTP
- Certificate pinning (future mobile enhancement)

</details>

---

## Compliance

<details>
<summary><b>GDPR Compliance</b></summary>

### User Rights
1. **Right to Access**: Users can export their data
2. **Right to Rectification**: Users can edit their profile
3. **Right to Erasure**: Users can delete their account
4. **Right to Data Portability**: Export data in JSON format
5. **Right to Object**: Opt-out of data processing (analytics)

### Data Processing
- **Privacy Policy**: Required, link in app footer
- **Terms of Service**: Required before sign-up
- **Cookie Consent**: For web version (if tracking enabled)
- **Data Breach Notification**: 72-hour requirement

</details>

<details>
<summary><b>COPPA Compliance (Children's Privacy)</b></summary>

- **Minimum age**: 13 years old (or 16 in EU)
- **Age verification**: Birthday field in registration (future)
- **Parental consent**: Required for under-13 users (if allowed)

</details>

---

## Security Checklist

- [x] JWT authentication with automatic refresh
- [x] Password hashing (bcrypt via Supabase)
- [x] Row Level Security enabled on all tables
- [x] Input validation (client & server)
- [x] SQL injection prevention (parameterized queries)
- [x] XSS prevention (sanitized inputs)
- [x] HTTPS only
- [x] Secure token storage (Keychain/Keystore)
- [x] Storage bucket policies
- [ ] Rate limiting (future)
- [ ] Two-factor authentication (future)
- [ ] Biometric login (future)
- [ ] Content moderation (future)
- [ ] Penetration testing (future)

---

**Last Updated:** February 5, 2026
