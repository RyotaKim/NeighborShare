# NeighborShare - Documentation Overview

## 📱 Application Overview

**NeighborShare** is a neighborhood-based item sharing and lending platform that connects community members to borrow and lend everyday items. The app eliminates the need to purchase rarely-used items by fostering a sharing economy within local communities.

---

## 📚 Documentation Index

This documentation is organized into separate files for easier navigation:

### 🛠️ [Tech Stack](docs/TECH_STACK.md)
Complete technology stack including Flutter, Supabase, Riverpod, and all dependencies with version information and rationale.

### 🗄️ [Database Schema](docs/DATABASE_SCHEMA.md)
Full PostgreSQL database schema for Supabase including all tables, Row Level Security policies, triggers, storage buckets, and setup scripts.

### ✨ [Features](docs/FEATURES.md)
Detailed breakdown of all core features including authentication, item feed, snap-to-list camera, availability toggle, and in-app chat.

### 🏗️ [Project Structure](docs/PROJECT_STRUCTURE.md)
Complete folder architecture with code examples, following Clean Architecture principles with feature-first organization.

### 🔐 [Security Implementation](docs/SECURITY.md)
Authentication flow, Row Level Security policies, data validation, and privacy features.

### 📱 [UI/UX Design](docs/UI_UX.md)
Design system, key screens, user flows, and interface guidelines.

### 🔄 [App Flow & User Journeys](docs/APP_FLOW.md)
Step-by-step user journeys for first-time users, borrowers, and lenders.

### 🚀 [Future Enhancements](docs/FUTURE_ENHANCEMENTS.md)
Planned features for Phase 2 and Phase 3 development.

### 🧪 [Testing Strategy](docs/TESTING.md)
Unit tests, widget tests, and integration test approaches.

### 📦 [Deployment](docs/DEPLOYMENT.md)
Build configuration for Android, iOS, and environment setup.

---

## 🛠️ Tech Stack

<details>
<summary><b>Frontend Framework</b></summary>

- **Flutter 3.10.8+**
  - Cross-platform mobile development (iOS, Android, Web)
  - Single codebase for all platforms
  - Hot reload for rapid development
  - Material Design 3 components

</details>

<details>
<summary><b>Backend & Database</b></summary>

- **Supabase**
  - PostgreSQL database with real-time subscriptions
  - Built-in authentication with JWT tokens
  - Row Level Security (RLS) for data protection
  - Storage for image uploads
  - Edge Functions for serverless logic
  - Realtime websocket connections

</details>

<details>
<summary><b>State Management</b></summary>

- **Riverpod 2.4.9+**
  - Compile-safe provider system
  - Improved testability over Provider
  - Better performance with granular rebuilds
  - Built-in caching and async support

</details>

<details>
<summary><b>Navigation</b></summary>

- **GoRouter 13.2.0+**
  - Declarative routing
  - Deep linking support
  - URL-based navigation for web
  - Protected routes for authentication

</details>

<details>
<summary><b>Camera & Media</b></summary>

- **camera: ^0.10.5+9** - Native camera access
- **image_picker: ^1.0.7** - Gallery and camera image selection
- **flutter_image_compress: ^2.1.0** - Image optimization
- **cached_network_image: ^3.3.1** - Efficient image caching

</details>

<details>
<summary><b>UI Components</b></summary>

- **flutter_chat_ui: ^1.6.12** - Pre-built chat interface
- **Material Design 3** - Modern UI components
- **Custom widgets** - Reusable component library

</details>

<details>
<summary><b>Utilities</b></summary>

- **intl: ^0.19.0** - Internationalization and date formatting
- **uuid: ^4.3.3** - Unique identifier generation
- **flutter_dotenv: ^5.1.0** - Environment variable management

</details>

---

## ✨ Core Features

<details>
<summary><b>1. User Authentication & Profiles</b></summary>

### Authentication
- **Email/Password Registration** with email verification
- **Secure Login** with JWT token management
- **Session Persistence** across app restarts
- **Password Reset** via email
- **Automatic Token Refresh** handled by Supabase

### User Profile
- Profile creation with username, full name, avatar
- Neighborhood/community assignment
- Edit profile information
- View personal item listings
- Track lending/borrowing history

**User Flow:**
```
New User → Register → Email Verification → Profile Setup → Home Feed
Returning User → Login → JWT Validation → Home Feed
```

</details>

<details>
<summary><b>2. Item Feed (Browse & Discover)</b></summary>

### Browse Items
- **Grid/List View** of all available items in neighborhood
- **Real-time Updates** when items are added/removed
- **Item Cards** showing:
  - Item photo
  - Title and brief description
  - Category badge
  - Availability status (Available/On Loan)
  - Owner information

### Category Filtering
Four main categories with visual icons:
- 🔧 **Tools** (drills, hammers, ladders, power tools)
- 🍳 **Kitchen** (appliances, cookware, specialty items)
- 🏕️ **Outdoor** (camping gear, sports equipment, gardening)
- 🎮 **Games** (board games, consoles, party games)

### Search & Sort
- Search by item name/description
- Sort by: Recently Added, Alphabetical, Distance (future)
- Filter by availability status

**User Flow:**
```
Home Feed → Filter by Category → Tap Item → View Details → Request to Borrow
```

</details>

<details>
<summary><b>3. Snap-to-List (Add Items)</b></summary>

### Camera Integration
- **Tap '+' Button** to add new item
- **Choose Source:**
  - Take Photo with camera
  - Select from Gallery
- **Image Preview** with retake option
- **Automatic Upload** to Supabase Storage

### Item Creation Form
- **Title** (required) - e.g., "Cordless Drill"
- **Description** (optional) - Condition, special notes
- **Category Selection** - Tools/Kitchen/Outdoor/Games
- **Initial Status** - Defaults to "Available"

### Image Processing
- Compress images before upload (max 2MB)
- Generate thumbnail for feed view
- Store full resolution for detail view

**User Flow:**
```
Tap '+' → Take/Select Photo → Add Title & Description → Select Category → Publish
```

</details>

<details>
<summary><b>4. Availability Toggle</b></summary>

### Status Management
- **Two States:**
  - ✅ **Available** - Ready to lend
  - 🔒 **On Loan** - Currently borrowed

### Toggle Controls
- **Switch Widget** on item detail screen (owner only)
- **Real-time Update** visible to all users immediately
- **Prevents Multiple Requests** when item is on loan
- **Automatic History Tracking** of status changes

### Notifications (Future Enhancement)
- Notify borrower when item becomes available
- Remind owner to update status after return

**User Flow:**
```
Owner → My Items → Select Item → Toggle Switch → Status Updated
```

</details>

<details>
<summary><b>5. In-App Chat System</b></summary>

### Conversation Features
- **Private 1-on-1 Messaging** between borrower and lender
- **Item-Specific Chats** - Each conversation linked to an item
- **Real-time Message Delivery** via Supabase Realtime
- **Message History** stored permanently

### Chat Interface
- **Modern Chat UI** with bubble design
- **Timestamp Display** for each message
- **Read Receipts** (future)
- **Image Sharing** in chat (future)

### Privacy Protection
- No phone numbers shared until users agree
- Block/Report functionality
- Messages deleted when conversation is removed

### Conversation Management
- **Inbox View** showing all active chats
- **Unread Message Badge** counts
- **Archive Completed Conversations**
- **Search Past Messages**

**User Flow:**
```
Item Detail → "Ask to Borrow" → Start Conversation → Send Messages → Agree on Pickup
```

</details>

---

## 🔄 App Flow & User Journey

<details>
<summary><b>First-Time User Journey</b></summary>

1. **Download App** → Splash Screen
2. **Welcome Screen** → "Sign Up" or "Log In"
3. **Register** → Enter email, password, username
4. **Email Verification** → Click link in email
5. **Profile Setup** → Add name, neighborhood, profile photo
6. **Tutorial Overlay** → Quick guide to main features
7. **Home Feed** → Browse available items
8. **Add First Item** → Snap-to-List walkthrough
9. **Explore Categories** → Filter and search items

</details>

<details>
<summary><b>Borrower Journey</b></summary>

1. **Open App** → Auto-login with saved JWT
2. **Browse Feed** → Filter by category (e.g., "Tools")
3. **Find Item** → Tap "Cordless Drill"
4. **View Details** → Check availability, photos, description
5. **Request to Borrow** → Tap "Ask to Borrow" button
6. **Start Chat** → "Hi! Could I borrow this tomorrow?"
7. **Coordinate Pickup** → Agree on time and location
8. **Receive Item** → Meet owner, collect item
9. **Return Item** → Arrange return via chat
10. **Leave Feedback** → (Optional: Rate experience)

</details>

<details>
<summary><b>Lender Journey</b></summary>

1. **Open App** → Auto-login
2. **Tap '+' Button** → Add new item
3. **Take Photo** → Capture image of ladder
4. **Fill Details** → Title: "Extension Ladder 24ft", Category: "Tools"
5. **Publish** → Item appears in feed as "Available"
6. **Receive Request** → Notification: "John wants to borrow your ladder"
7. **Open Chat** → Discuss pickup details
8. **Lend Item** → Meet borrower, hand over ladder
9. **Toggle Status** → Set to "On Loan"
10. **Item Returned** → Toggle back to "Available"

</details>

---

## 🗄️ Database Schema (Supabase)

<details>
<summary><b>Schema Overview</b></summary>

The database consists of 5 main tables with relationships:
- `profiles` - Extended user information
- `items` - Shareable items catalog
- `conversations` - Chat sessions
- `conversation_participants` - Many-to-many for users in chats
- `messages` - Individual chat messages

</details>

<details>
<summary><b>Table: profiles</b></summary>

### Purpose
Extends Supabase Auth's default `auth.users` table with custom user data.

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

-- Index for faster lookups
CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_neighborhood ON profiles(neighborhood);
```

### Fields
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key, references auth.users |
| `username` | TEXT | Unique display name (3+ chars) |
| `full_name` | TEXT | User's real name (optional) |
| `avatar_url` | TEXT | Profile picture URL in Supabase Storage |
| `neighborhood` | TEXT | Community/area identifier |
| `bio` | TEXT | Short user description |
| `created_at` | TIMESTAMPTZ | Account creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last profile update |

### Row Level Security (RLS)
```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can read all profiles
CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### Triggers
```sql
-- Auto-update updated_at timestamp
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

</details>

<details>
<summary><b>Table: items</b></summary>

### Purpose
Stores all shareable items listed by users.

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
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key, auto-generated |
| `user_id` | UUID | Owner reference (profiles table) |
| `title` | TEXT | Item name (3+ chars) |
| `description` | TEXT | Detailed description, condition |
| `category` | TEXT | Tools/Kitchen/Outdoor/Games |
| `image_url` | TEXT | Full-size image URL |
| `thumbnail_url` | TEXT | Optimized thumbnail URL |
| `status` | TEXT | Available or On Loan |
| `created_at` | TIMESTAMPTZ | When item was listed |
| `updated_at` | TIMESTAMPTZ | Last modification time |

### Row Level Security (RLS)
```sql
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- Everyone can view available items
CREATE POLICY "Items are viewable by everyone"
  ON items FOR SELECT
  USING (true);

-- Authenticated users can create items
CREATE POLICY "Authenticated users can create items"
  ON items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can only update their own items
CREATE POLICY "Users can update own items"
  ON items FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can only delete their own items
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

</details>

<details>
<summary><b>Table: conversations</b></summary>

### Purpose
Represents chat sessions between users about specific items.

### Schema
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID REFERENCES items(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_message_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_conversations_item_id ON conversations(item_id);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);
```

### Fields
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `item_id` | UUID | Related item being discussed |
| `created_at` | TIMESTAMPTZ | Conversation start time |
| `last_message_at` | TIMESTAMPTZ | Timestamp of most recent message |

### Row Level Security (RLS)
```sql
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

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

-- Users can create conversations
CREATE POLICY "Users can create conversations"
  ON conversations FOR INSERT
  WITH CHECK (true);
```

</details>

<details>
<summary><b>Table: conversation_participants</b></summary>

### Purpose
Junction table managing which users are in which conversations (many-to-many).

### Schema
```sql
CREATE TABLE conversation_participants (
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (conversation_id, user_id)
);

-- Indexes
CREATE INDEX idx_participants_user_id ON conversation_participants(user_id);
CREATE INDEX idx_participants_conversation_id ON conversation_participants(conversation_id);
```

### Fields
| Column | Type | Description |
|--------|------|-------------|
| `conversation_id` | UUID | Reference to conversation |
| `user_id` | UUID | Reference to participant |
| `joined_at` | TIMESTAMPTZ | When user joined chat |

### Row Level Security (RLS)
```sql
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;

-- Users can view participants in their conversations
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

-- Users can add themselves to conversations
CREATE POLICY "Users can join conversations"
  ON conversation_participants FOR INSERT
  WITH CHECK (user_id = auth.uid());
```

</details>

<details>
<summary><b>Table: messages</b></summary>

### Purpose
Stores individual chat messages within conversations.

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
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `conversation_id` | UUID | Parent conversation |
| `sender_id` | UUID | User who sent message |
| `content` | TEXT | Message text content |
| `created_at` | TIMESTAMPTZ | When message was sent |
| `read_at` | TIMESTAMPTZ | When message was read (nullable) |

### Row Level Security (RLS)
```sql
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Users can view messages in their conversations
CREATE POLICY "Users can view messages in their conversations"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = messages.conversation_id
      AND user_id = auth.uid()
    )
  );

-- Users can send messages to their conversations
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

</details>

<details>
<summary><b>Supabase Storage Buckets</b></summary>

### Bucket: item-images
- **Purpose:** Store full-size item photos
- **Public Access:** Yes (read-only)
- **Size Limit:** 5MB per file
- **Allowed Types:** image/jpeg, image/png, image/webp

```sql
-- Create bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('item-images', 'item-images', true);

-- Storage policies
CREATE POLICY "Item images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'item-images');

CREATE POLICY "Authenticated users can upload item images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'item-images' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Users can update own item images"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'item-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

### Bucket: avatars
- **Purpose:** Store user profile pictures
- **Public Access:** Yes (read-only)
- **Size Limit:** 2MB per file
- **Allowed Types:** image/jpeg, image/png

```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- Storage policies
CREATE POLICY "Avatars are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

</details>

<details>
<summary><b>Database Functions & Views</b></summary>

### Function: Get User's Items Count
```sql
CREATE OR REPLACE FUNCTION get_user_items_count(user_uuid UUID)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER
  FROM items
  WHERE user_id = user_uuid;
$$ LANGUAGE SQL STABLE;
```

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

### View: Items with Owner Info
```sql
CREATE VIEW items_with_owner AS
SELECT 
  i.*,
  p.username as owner_username,
  p.full_name as owner_name,
  p.avatar_url as owner_avatar,
  p.neighborhood as owner_neighborhood
FROM items i
JOIN profiles p ON i.user_id = p.id;
```

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

</details>

<details>
<summary><b>Realtime Subscriptions</b></summary>

### Enable Realtime for Tables
```sql
-- Enable realtime for items table
ALTER PUBLICATION supabase_realtime ADD TABLE items;

-- Enable realtime for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Enable realtime for conversations table
ALTER PUBLICATION supabase_realtime ADD TABLE conversations;
```

### Flutter Implementation Example
```dart
// Subscribe to new items in feed
final itemsSubscription = supabase
  .from('items')
  .stream(primaryKey: ['id'])
  .eq('status', 'Available')
  .listen((List<Map<String, dynamic>> data) {
    // Update UI with new items
  });

// Subscribe to messages in a conversation
final messagesSubscription = supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .eq('conversation_id', conversationId)
  .order('created_at')
  .listen((List<Map<String, dynamic>> data) {
    // Display new messages in real-time
  });
```

</details>

---

## 🏗️ Project Structure

<details>
<summary><b>Recommended Folder Architecture</b></summary>

```
lib/
├── main.dart                           # App entry point with Supabase initialization
│
├── app/
│   ├── app.dart                        # MaterialApp configuration
│   └── router.dart                     # GoRouter setup with routes
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart          # App-wide constants
│   │   ├── supabase_constants.dart     # API keys, bucket names
│   │   └── category_constants.dart     # Category enum and data
│   │
│   ├── services/
│   │   ├── supabase_service.dart       # Supabase client wrapper
│   │   ├── auth_service.dart           # Authentication logic
│   │   ├── storage_service.dart        # File upload/download
│   │   └── realtime_service.dart       # Realtime subscriptions manager
│   │
│   ├── utils/
│   │   ├── image_utils.dart            # Image compression, processing
│   │   ├── date_utils.dart             # Date formatting helpers
│   │   └── validators.dart             # Form validation functions
│   │
│   └── errors/
│       ├── app_exception.dart          # Custom exception classes
│       └── error_handler.dart          # Global error handling
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   │
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── user_entity.dart
│   │   │
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   ├── forgot_password_screen.dart
│   │       │   └── profile_setup_screen.dart
│   │       │
│   │       ├── widgets/
│   │       │   ├── auth_form.dart
│   │       │   └── password_field.dart
│   │       │
│   │       └── providers/
│   │           └── auth_provider.dart
│   │
│   ├── items/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── item_model.dart
│   │   │   └── repositories/
│   │   │       └── item_repository.dart
│   │   │
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── item_entity.dart
│   │   │
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── item_feed_screen.dart
│   │       │   ├── item_detail_screen.dart
│   │       │   ├── add_item_screen.dart
│   │       │   └── my_items_screen.dart
│   │       │
│   │       ├── widgets/
│   │       │   ├── item_card.dart
│   │       │   ├── category_filter.dart
│   │       │   ├── availability_toggle.dart
│   │       │   ├── item_image_picker.dart
│   │       │   └── category_selector.dart
│   │       │
│   │       └── providers/
│   │           ├── items_provider.dart
│   │           ├── item_detail_provider.dart
│   │           └── my_items_provider.dart
│   │
│   ├── chat/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── message_model.dart
│   │   │   │   └── conversation_model.dart
│   │   │   └── repositories/
│   │   │       └── chat_repository.dart
│   │   │
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       ├── message_entity.dart
│   │   │       └── conversation_entity.dart
│   │   │
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── conversations_screen.dart
│   │       │   └── chat_screen.dart
│   │       │
│   │       ├── widgets/
│   │       │   ├── message_bubble.dart
│   │       │   ├── conversation_tile.dart
│   │       │   └── chat_input.dart
│   │       │
│   │       └── providers/
│   │           ├── conversations_provider.dart
│   │           └── messages_provider.dart
│   │
│   └── profile/
│       ├── data/
│       │   ├── models/
│       │   │   └── profile_model.dart
│       │   └── repositories/
│       │       └── profile_repository.dart
│       │
│       ├── domain/
│       │   └── entities/
│       │       └── profile_entity.dart
│       │
│       └── presentation/
│           ├── screens/
│           │   ├── profile_screen.dart
│           │   └── edit_profile_screen.dart
│           │
│           ├── widgets/
│           │   ├── profile_header.dart
│           │   └── profile_stats.dart
│           │
│           └── providers/
│               └── profile_provider.dart
│
├── shared/
│   ├── widgets/
│   │   ├── app_bar.dart
│   │   ├── bottom_nav_bar.dart
│   │   ├── loading_indicator.dart
│   │   ├── error_widget.dart
│   │   ├── empty_state.dart
│   │   └── custom_button.dart
│   │
│   └── theme/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── text_styles.dart
│
└── config/
    └── env.dart                        # Environment configuration
```

</details>

---

## 🔐 Security Implementation

<details>
<summary><b>Authentication Flow</b></summary>

### JWT Token Management
```dart
// Automatic token refresh handled by Supabase
final session = supabase.auth.currentSession;
final accessToken = session?.accessToken; // JWT token
final refreshToken = session?.refreshToken;

// Token is automatically included in all authenticated requests
```

### Protected Routes
```dart
// router.dart
GoRoute(
  path: '/home',
  builder: (context, state) => const HomeFeedScreen(),
  redirect: (context, state) {
    final isAuthenticated = supabase.auth.currentUser != null;
    if (!isAuthenticated) return '/login';
    return null;
  },
)
```

</details>

<details>
<summary><b>Row Level Security Policies</b></summary>

All database tables have RLS enabled ensuring:
- Users can only modify their own items
- Chat messages only visible to conversation participants
- Profile privacy controls
- Prevents unauthorized data access even if client is compromised

</details>

<details>
<summary><b>Data Validation</b></summary>

### Client-Side (Flutter)
- Form validation before submission
- Image size/type checks
- Input sanitization

### Server-Side (Supabase)
- Database constraints (CHECK, NOT NULL)
- Type validation
- Length limits
- Enum enforcement for categories/status

</details>

---

## 📱 UI/UX Design Principles

<details>
<summary><b>Design System</b></summary>

- **Material Design 3** with custom color scheme
- **Responsive Layouts** for tablets and foldables
- **Dark Mode Support** following system preferences
- **Accessibility** - Screen reader support, semantic labels
- **Haptic Feedback** for key interactions

</details>

<details>
<summary><b>Key Screens</b></summary>

1. **Splash Screen** - App logo with loading indicator
2. **Login/Register** - Clean form with social login (future)
3. **Home Feed** - Grid of item cards with category filters
4. **Item Detail** - Large image, description, availability, chat button
5. **Add Item** - Camera viewfinder, form overlay
6. **My Items** - List of user's listings with edit options
7. **Chat Inbox** - List of conversations with unread badges
8. **Chat View** - Message bubbles, input field, image sharing
9. **Profile** - Avatar, stats, settings

</details>

---

## 🚀 Future Enhancements

<details>
<summary><b>Phase 2 Features</b></summary>

- **Ratings & Reviews** - Trust system for reliable lenders/borrowers
- **Geolocation Filtering** - Show items within X miles
- **Push Notifications** - New messages, item requests
- **Item Request Queue** - Multiple users can request same item
- **Lending Calendar** - Schedule future item availability
- **Social Sharing** - Share items to social media

</details>

<details>
<summary><b>Phase 3 Features</b></summary>

- **In-App Payments** - Optional rental fees (micro-transactions)
- **Insurance Integration** - Protect valuable items
- **Community Guidelines** - Dispute resolution system
- **Neighborhood Verification** - Confirm actual location
- **Item Tags** - More granular search (brand, condition, year)
- **Wishlist** - Get notified when requested items are available

</details>

---

## 📊 Analytics & Monitoring

<details>
<summary><b>Key Metrics to Track</b></summary>

- Daily Active Users (DAU)
- Items listed per user
- Borrowing success rate (chat initiated → item lent)
- Average response time in chat
- Category popularity
- User retention (7-day, 30-day)
- Crash reports and error rates

</details>

---

## 🧪 Testing Strategy

<details>
<summary><b>Testing Approach</b></summary>

### Unit Tests
- Repository methods
- Business logic in providers
- Utility functions

### Widget Tests
- Individual widget rendering
- User interaction flows
- Form validation

### Integration Tests
- End-to-end user flows
- Supabase integration
- Camera functionality

</details>

---

## 📦 Deployment

<details>
<summary><b>Build Configuration</b></summary>

### Android
- `minSdkVersion: 21`
- `targetSdkVersion: 34`
- Camera permissions in AndroidManifest.xml

### iOS
- `iOS 13.0+`
- Camera usage description in Info.plist
- Photo library access permission

### Environment Variables
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

</details>

---

## 🔧 Common Patterns & Best Practices

<details>
<summary><b>Import Aliases for Color Classes</b></summary>

When importing colors.dart in files that also import category_constants.dart, 
use an alias to avoid conflicts:

```dart
import '../../../../core/constants/category_constants.dart';
import '../../../../shared/theme/colors.dart' as theme_colors;

// Usage:
final categoryColor = theme_colors.CategoryColors.getColor(category);
final statusColor = theme_colors.StatusColors.getColor(status);
```

</details>

<details>
<summary><b>Auth State Access</b></summary>

Correct way to access user ID from auth state:

```dart
final authState = ref.watch(authStateProvider);
final userId = authState.value?.session?.user.id;  // ✅ Correct

// ❌ Wrong: authState.value?.uid
// ❌ Wrong: authState.value?.user?.id
```

</details>

<details>
<summary><b>Supabase Query Filtering</b></summary>

Chain filter methods before applying ordering and pagination:

```dart
// ✅ Correct:
var query = _client.from('table').select();

// Apply filters
if (category != null) {
  query = query.eq('category', category.toDbString());
}

if (searchQuery != null) {
  query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
}

// Then apply ordering and pagination
final response = await query
    .order('created_at', ascending: false)
    .range(offset, offset + limit - 1);
```

</details>

<details>
<summary><b>Empty State & Error Display Widgets</b></summary>

Correct parameter names:

```dart
// Empty State
EmptyState(
  title: 'No items',
  description: 'Description text',
  actionButtonText: 'Add Item',  // ✅ Correct
  onActionPressed: () {},         // ✅ Correct
)

// Error Display
ErrorDisplay(
  message: 'Error message',
  onRetry: () {},  // No 'error' parameter
)
```

</details>

<details>
<summary><b>Enum-Based Helper Methods</b></summary>

Color helper classes provide enum-based methods for type safety:

```dart
// StatusColors accepts ItemStatus enum
final color = theme_colors.StatusColors.getColor(ItemStatus.available);

// CategoryColors accepts ItemCategory enum
final color = theme_colors.CategoryColors.getColor(ItemCategory.tools);

// Also provides static properties for direct access
final toolsColor = theme_colors.CategoryColors.tools;
final kitchenColor = theme_colors.CategoryColors.kitchen;
```

</details>

---

**Last Updated:** February 5, 2026  
**Version:** 1.0.0  
**Author:** NeighborShare Development Team
