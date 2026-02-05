# Database Schema - NeighborShare

## Overview
Complete PostgreSQL database schema for Supabase backend with Row Level Security policies.

---

## Schema Overview

<details>
<summary><b>Database Structure</b></summary>

The database consists of **5 main tables** with relationships:

1. **profiles** - Extended user information
2. **items** - Shareable items catalog
3. **conversations** - Chat sessions
4. **conversation_participants** - Many-to-many for users in chats
5. **messages** - Individual chat messages

### Entity Relationship Diagram
```
auth.users (Supabase Auth)
    ↓ (1:1)
profiles
    ↓ (1:N)
items ←→ conversations
         ↓ (N:M)
    conversation_participants
         ↓ (1:N)
    messages
```

</details>

---

## Table: profiles

<details>
<summary><b>User Profile Extension</b></summary>

### Purpose
Extends Supabase Auth's default `auth.users` table with custom user data and application-specific information.

### Schema
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  neighborhood TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT username_length CHECK (char_length(username) >= 3)
);

-- Indexes for faster lookups
CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_neighborhood ON profiles(neighborhood);
```

### Fields

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | UUID | NO | Primary key, references auth.users(id) |
| `username` | TEXT | NO | Unique display name (3+ chars) |
| `full_name` | TEXT | YES | User's real name (optional) |
| `avatar_url` | TEXT | YES | Profile picture URL in Supabase Storage |
| `neighborhood` | TEXT | YES | Community/area identifier |
| `bio` | TEXT | YES | Short user description |
| `created_at` | TIMESTAMPTZ | NO | Account creation timestamp |
| `updated_at` | TIMESTAMPTZ | NO | Last profile update |

### Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read all profiles
CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

-- Policy: Users can only update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### Triggers

```sql
-- Auto-update updated_at timestamp on any update
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_updated_at();
```

### Sample Data
```sql
INSERT INTO profiles (id, username, full_name, neighborhood)
VALUES 
  ('user-uuid-1', 'john_doe', 'John Doe', 'Downtown'),
  ('user-uuid-2', 'jane_smith', 'Jane Smith', 'Uptown');
```

</details>

---

## Table: items

<details>
<summary><b>Shareable Items Catalog</b></summary>

### Purpose
Stores all shareable items listed by users with category classification and availability status.

### Schema
```sql
CREATE TABLE items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (
    category IN ('Tools', 'Kitchen', 'Outdoor', 'Games')
  ),
  image_url TEXT,
  thumbnail_url TEXT,
  status TEXT DEFAULT 'Available' CHECK (
    status IN ('Available', 'On Loan')
  ),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT title_length CHECK (char_length(title) >= 3)
);

-- Indexes for performance
CREATE INDEX idx_items_user_id ON items(user_id);
CREATE INDEX idx_items_category ON items(category);
CREATE INDEX idx_items_status ON items(status);
CREATE INDEX idx_items_created_at ON items(created_at DESC);
```

### Fields

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | UUID | NO | Primary key, auto-generated |
| `user_id` | UUID | NO | Owner reference (profiles table) |
| `title` | TEXT | NO | Item name (3+ chars) |
| `description` | TEXT | YES | Detailed description, condition notes |
| `category` | TEXT | NO | Tools/Kitchen/Outdoor/Games |
| `image_url` | TEXT | YES | Full-size image URL from Storage |
| `thumbnail_url` | TEXT | YES | Optimized thumbnail URL (300x300) |
| `status` | TEXT | NO | Available or On Loan (default: Available) |
| `created_at` | TIMESTAMPTZ | NO | When item was listed |
| `updated_at` | TIMESTAMPTZ | NO | Last modification time |

### Categories

| Category | Icon | Examples |
|----------|------|----------|
| Tools | 🔧 | Drill, hammer, ladder, saw, power tools |
| Kitchen | 🍳 | Mixer, pressure cooker, waffle maker |
| Outdoor | 🏕️ | Tent, camping gear, sports equipment |
| Games | 🎮 | Board games, video game consoles |

### Row Level Security (RLS)

```sql
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can view all items
CREATE POLICY "Items are viewable by everyone"
  ON items FOR SELECT
  USING (true);

-- Policy: Authenticated users can create items
CREATE POLICY "Authenticated users can create items"
  ON items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only update their own items
CREATE POLICY "Users can update own items"
  ON items FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can only delete their own items
CREATE POLICY "Users can delete own items"
  ON items FOR DELETE
  USING (auth.uid() = user_id);
```

### Triggers

```sql
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON items
  FOR EACH ROW
  EXECUTE FUNCTION handle_updated_at();
```

### Sample Data
```sql
INSERT INTO items (user_id, title, description, category, status)
VALUES 
  ('user-uuid-1', 'Cordless Drill', 'DeWalt 20V, barely used', 'Tools', 'Available'),
  ('user-uuid-2', 'Instant Pot', '6-quart pressure cooker', 'Kitchen', 'On Loan');
```

</details>

---

## Table: conversations

<details>
<summary><b>Chat Sessions</b></summary>

### Purpose
Represents chat sessions between users about specific items. Each conversation is tied to one item.

### Schema
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID REFERENCES items(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_message_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_conversations_item_id ON conversations(item_id);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);
```

### Fields

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | UUID | NO | Primary key |
| `item_id` | UUID | NO | Related item being discussed |
| `created_at` | TIMESTAMPTZ | NO | Conversation start time |
| `last_message_at` | TIMESTAMPTZ | NO | Timestamp of most recent message |

### Row Level Security (RLS)

```sql
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see conversations they're part of
CREATE POLICY "Users can view own conversations"
  ON conversations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = id
      AND user_id = auth.uid()
    )
  );

-- Policy: Any authenticated user can create conversations
CREATE POLICY "Users can create conversations"
  ON conversations FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');
```

### Sample Data
```sql
INSERT INTO conversations (item_id)
VALUES ('item-uuid-1');
```

</details>

---

## Table: conversation_participants

<details>
<summary><b>Chat Participants (Junction Table)</b></summary>

### Purpose
Junction table managing which users are in which conversations (many-to-many relationship). Typically 2 users per conversation (borrower + lender).

### Schema
```sql
CREATE TABLE conversation_participants (
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (conversation_id, user_id)
);

-- Indexes for faster queries
CREATE INDEX idx_participants_user_id ON conversation_participants(user_id);
CREATE INDEX idx_participants_conversation_id ON conversation_participants(conversation_id);
```

### Fields

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `conversation_id` | UUID | NO | Reference to conversation |
| `user_id` | UUID | NO | Reference to participant (profiles) |
| `joined_at` | TIMESTAMPTZ | NO | When user joined chat |

**Composite Primary Key:** `(conversation_id, user_id)`

### Row Level Security (RLS)

```sql
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view participants in their conversations
CREATE POLICY "Users can view conversation participants"
  ON conversation_participants FOR SELECT
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM conversation_participants cp
      WHERE cp.conversation_id = conversation_id
      AND cp.user_id = auth.uid()
    )
  );

-- Policy: Users can add themselves to conversations
CREATE POLICY "Users can join conversations"
  ON conversation_participants FOR INSERT
  WITH CHECK (user_id = auth.uid());
```

### Sample Data
```sql
INSERT INTO conversation_participants (conversation_id, user_id)
VALUES 
  ('convo-uuid-1', 'user-uuid-1'),  -- Item owner
  ('convo-uuid-1', 'user-uuid-2');  -- Borrower
```

</details>

---

## Table: messages

<details>
<summary><b>Chat Messages</b></summary>

### Purpose
Stores individual chat messages within conversations. Supports real-time message delivery.

### Schema
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ,
  
  CONSTRAINT content_not_empty CHECK (char_length(trim(content)) > 0)
);

-- Indexes for fast message retrieval
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
```

### Fields

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | UUID | NO | Primary key |
| `conversation_id` | UUID | NO | Parent conversation |
| `sender_id` | UUID | NO | User who sent message |
| `content` | TEXT | NO | Message text content (non-empty) |
| `created_at` | TIMESTAMPTZ | NO | When message was sent |
| `read_at` | TIMESTAMPTZ | YES | When message was read (null = unread) |

### Row Level Security (RLS)

```sql
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view messages in their conversations
CREATE POLICY "Users can view messages in their conversations"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = messages.conversation_id
      AND user_id = auth.uid()
    )
  );

-- Policy: Users can send messages to their conversations
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

### Triggers

```sql
-- Update conversation's last_message_at on new message
CREATE OR REPLACE FUNCTION update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations
  SET last_message_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_last_message
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_conversation_timestamp();
```

### Sample Data
```sql
INSERT INTO messages (conversation_id, sender_id, content)
VALUES 
  ('convo-uuid-1', 'user-uuid-2', 'Hi! Can I borrow your drill tomorrow?'),
  ('convo-uuid-1', 'user-uuid-1', 'Sure! When do you need it?');
```

</details>

---

## Storage Buckets

<details>
<summary><b>Supabase Storage Configuration</b></summary>

### Bucket: item-images

**Purpose:** Store full-size item photos

```sql
-- Create bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('item-images', 'item-images', true);
```

**Configuration:**
- Public Access: Yes (read-only)
- Size Limit: 5MB per file
- Allowed Types: `image/jpeg`, `image/png`, `image/webp`

**Storage Policies:**
```sql
-- Anyone can view item images
CREATE POLICY "Item images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'item-images');

-- Authenticated users can upload
CREATE POLICY "Authenticated users can upload item images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'item-images' AND
    auth.role() = 'authenticated'
  );

-- Users can update their own images
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
  ├── {user_id}/
  │   ├── {item_id}_full.jpg
  │   └── {item_id}_thumb.jpg
```

---

### Bucket: avatars

**Purpose:** Store user profile pictures

```sql
-- Create bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);
```

**Configuration:**
- Public Access: Yes (read-only)
- Size Limit: 2MB per file
- Allowed Types: `image/jpeg`, `image/png`

**Storage Policies:**
```sql
-- Anyone can view avatars
CREATE POLICY "Avatars are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

-- Users can upload own avatar
CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can update own avatar
CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

**File Path Structure:**
```
avatars/
  ├── {user_id}/
  │   └── avatar.jpg
```

</details>

---

## Database Functions

<details>
<summary><b>Helper Functions</b></summary>

### Function: Get User's Items Count

```sql
CREATE OR REPLACE FUNCTION get_user_items_count(user_uuid UUID)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER
  FROM items
  WHERE user_id = user_uuid;
$$ LANGUAGE SQL STABLE;
```

**Usage:**
```sql
SELECT get_user_items_count('user-uuid-1');
-- Returns: 5
```

---

### Function: Get Available Items by Category

```sql
CREATE OR REPLACE FUNCTION get_available_items_by_category(cat TEXT)
RETURNS SETOF items AS $$
  SELECT *
  FROM items
  WHERE category = cat
  AND status = 'Available'
  ORDER BY created_at DESC;
$$ LANGUAGE SQL STABLE;
```

**Usage:**
```sql
SELECT * FROM get_available_items_by_category('Tools');
```

</details>

---

## Database Views

<details>
<summary><b>Materialized and Regular Views</b></summary>

### View: Items with Owner Info

```sql
CREATE VIEW items_with_owner AS
SELECT 
  i.id,
  i.title,
  i.description,
  i.category,
  i.image_url,
  i.thumbnail_url,
  i.status,
  i.created_at,
  i.updated_at,
  p.id as owner_id,
  p.username as owner_username,
  p.full_name as owner_name,
  p.avatar_url as owner_avatar,
  p.neighborhood as owner_neighborhood
FROM items i
JOIN profiles p ON i.user_id = p.id;
```

**Usage in Flutter:**
```dart
final items = await supabase
  .from('items_with_owner')
  .select()
  .eq('status', 'Available');
```

---

### View: Unread Messages Count

```sql
CREATE VIEW unread_messages_count AS
SELECT 
  cp.user_id,
  cp.conversation_id,
  COUNT(m.id) as unread_count
FROM conversation_participants cp
JOIN messages m ON m.conversation_id = cp.conversation_id
WHERE m.sender_id != cp.user_id
AND m.read_at IS NULL
GROUP BY cp.user_id, cp.conversation_id;
```

**Usage in Flutter:**
```dart
final unreadCounts = await supabase
  .from('unread_messages_count')
  .select()
  .eq('user_id', currentUserId);
```

</details>

---

## Realtime Subscriptions

<details>
<summary><b>Enable Realtime Features</b></summary>

### Enable Realtime for Tables

```sql
-- Enable realtime for items table
ALTER PUBLICATION supabase_realtime ADD TABLE items;

-- Enable realtime for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Enable realtime for conversations table
ALTER PUBLICATION supabase_realtime ADD TABLE conversations;
```

### Flutter Implementation

**Subscribe to New Items:**
```dart
final itemsSubscription = supabase
  .from('items')
  .stream(primaryKey: ['id'])
  .eq('status', 'Available')
  .listen((List<Map<String, dynamic>> data) {
    // Update UI with new items in real-time
    print('Received ${data.length} items');
  });
```

**Subscribe to Messages in Conversation:**
```dart
final messagesSubscription = supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .eq('conversation_id', conversationId)
  .order('created_at')
  .listen((List<Map<String, dynamic>> data) {
    // Display new messages in real-time
    setState(() {
      messages = data.map((m) => Message.fromJson(m)).toList();
    });
  });
```

**Clean up subscriptions:**
```dart
@override
void dispose() {
  itemsSubscription.cancel();
  messagesSubscription.cancel();
  super.dispose();
}
```

</details>

---

## Setup Script

<details>
<summary><b>Complete Database Setup SQL</b></summary>

```sql
-- ============================================
-- NeighborShare Database Setup Script
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  neighborhood TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT username_length CHECK (char_length(username) >= 3)
);

CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_neighborhood ON profiles(neighborhood);

-- 2. Create items table
CREATE TABLE items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('Tools', 'Kitchen', 'Outdoor', 'Games')),
  image_url TEXT,
  thumbnail_url TEXT,
  status TEXT DEFAULT 'Available' CHECK (status IN ('Available', 'On Loan')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT title_length CHECK (char_length(title) >= 3)
);

CREATE INDEX idx_items_user_id ON items(user_id);
CREATE INDEX idx_items_category ON items(category);
CREATE INDEX idx_items_status ON items(status);
CREATE INDEX idx_items_created_at ON items(created_at DESC);

-- 3. Create conversations table
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID REFERENCES items(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_message_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conversations_item_id ON conversations(item_id);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);

-- 4. Create conversation_participants table
CREATE TABLE conversation_participants (
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (conversation_id, user_id)
);

CREATE INDEX idx_participants_user_id ON conversation_participants(user_id);
CREATE INDEX idx_participants_conversation_id ON conversation_participants(conversation_id);

-- 5. Create messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ,
  CONSTRAINT content_not_empty CHECK (char_length(trim(content)) > 0)
);

CREATE INDEX idx_messages_conversation_id ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);

-- 6. Create trigger function for updated_at
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Apply triggers
CREATE TRIGGER set_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON items
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- 8. Create trigger for conversation timestamp
CREATE OR REPLACE FUNCTION update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations
  SET last_message_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_last_message AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION update_conversation_timestamp();

-- 9. Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- 10. Create RLS Policies (profiles)
CREATE POLICY "Profiles are viewable by everyone" ON profiles
  FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 11. Create RLS Policies (items)
CREATE POLICY "Items are viewable by everyone" ON items
  FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create items" ON items
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own items" ON items
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own items" ON items
  FOR DELETE USING (auth.uid() = user_id);

-- 12. Create RLS Policies (conversations)
CREATE POLICY "Users can view own conversations" ON conversations
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = id AND user_id = auth.uid()
    )
  );
CREATE POLICY "Users can create conversations" ON conversations
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- 13. Create RLS Policies (conversation_participants)
CREATE POLICY "Users can view conversation participants" ON conversation_participants
  FOR SELECT USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM conversation_participants cp
      WHERE cp.conversation_id = conversation_id AND cp.user_id = auth.uid()
    )
  );
CREATE POLICY "Users can join conversations" ON conversation_participants
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- 14. Create RLS Policies (messages)
CREATE POLICY "Users can view messages in their conversations" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()
    )
  );
CREATE POLICY "Users can send messages to their conversations" ON messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()
    )
  );

-- 15. Create Views
CREATE VIEW items_with_owner AS
SELECT 
  i.*,
  p.username as owner_username,
  p.full_name as owner_name,
  p.avatar_url as owner_avatar,
  p.neighborhood as owner_neighborhood
FROM items i
JOIN profiles p ON i.user_id = p.id;

CREATE VIEW unread_messages_count AS
SELECT 
  cp.user_id,
  cp.conversation_id,
  COUNT(m.id) as unread_count
FROM conversation_participants cp
JOIN messages m ON m.conversation_id = cp.conversation_id
WHERE m.sender_id != cp.user_id AND m.read_at IS NULL
GROUP BY cp.user_id, cp.conversation_id;

-- 16. Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE items;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE conversations;

-- 17. Create Storage Buckets (run in Storage section)
-- item-images bucket (public, 5MB limit)
-- avatars bucket (public, 2MB limit)

-- Setup complete!
```

</details>

---

**Last Updated:** February 5, 2026
