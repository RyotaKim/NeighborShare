# Features - NeighborShare

## Overview
Detailed breakdown of all core features in the NeighborShare item lending platform.

---

## Feature 1: User Authentication & Profiles

<details>
<summary><b>Authentication System</b></summary>

### Registration
- **Email/Password signup** with validation
- **Email verification** required before access
- **Username uniqueness** check in real-time
- **Password requirements**: Min 8 characters
- **Terms of Service** acceptance

### Login
- **Secure login** with JWT token management
- **Session persistence** across app restarts
- **"Remember me"** functionality
- **Automatic token refresh** handled by Supabase
- **Biometric login** (fingerprint/face) - future

### Password Management
- **Forgot password** via email reset link
- **Password reset** with secure token
- **Change password** from profile settings

### Session Management
- **Automatic logout** after 30 days of inactivity
- **Multi-device support** with synchronized sessions
- **Force logout** from all devices option

### Technical Implementation
```dart
// Registration
final response = await supabase.auth.signUp(
  email: email,
  password: password,
  data: {'username': username},
);

// Login
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Check session
final session = supabase.auth.currentSession;
final user = supabase.auth.currentUser;
```

</details>

<details>
<summary><b>User Profiles</b></summary>

### Profile Creation
- **Username** (3-20 characters, unique, alphanumeric + underscore)
- **Full name** (optional, for trust building)
- **Avatar upload** (max 2MB, JPG/PNG)
- **Neighborhood** (text field or dropdown of nearby areas)
- **Bio** (short description, 500 char max)

### Profile Display
- **Profile picture** with fallback to initials
- **Username and full name**
- **Neighborhood badge**
- **Member since** date
- **Item statistics**: Total listed, Currently available, Times lent

### Profile Editing
- **Edit all profile fields** except username (locked after creation)
- **Change avatar** with crop functionality
- **Privacy settings** (hide full name, hide neighborhood)
- **Notification preferences**

### Profile Views
- **Own profile**: Edit button, full stats, logout option
- **Other users' profiles**: View-only, items listed, contact button

</details>

---

## Feature 2: Item Feed (Browse & Discover)

<details>
<summary><b>Main Feed Display</b></summary>

### Layout Options
- **Grid view** (2 columns) - default
- **List view** (single column with larger images)
- **Toggle button** in app bar to switch views

### Item Cards
Each card displays:
- **Item photo** (thumbnail 300x300)
- **Title** (bold, 2 lines max)
- **Category badge** (colored chip)
- **Availability status** (Available = green dot, On Loan = red dot)
- **Owner username** (small text)
- **Distance** (future: "0.5 mi away")

### Loading States
- **Skeleton loaders** while fetching data
- **Infinite scroll** pagination (load 20 items at a time)
- **Pull-to-refresh** to reload feed

### Real-time Updates
- **New items appear** automatically at top of feed
- **Status changes** reflect immediately (Available ↔ On Loan)
- **Deleted items** removed from feed without refresh

### Technical Implementation
```dart
// Realtime subscription
final itemsStream = supabase
  .from('items')
  .stream(primaryKey: ['id'])
  .eq('status', 'Available')
  .order('created_at', ascending: false);
```

</details>

<details>
<summary><b>Category Filtering</b></summary>

### Four Main Categories

#### 🔧 Tools
- Drills, hammers, screwdrivers
- Ladders, paint supplies
- Power tools, saws
- Measuring tools
- Gardening tools

#### 🍳 Kitchen
- Stand mixers, blenders
- Pressure cookers, air fryers
- Specialty appliances (waffle makers, bread machines)
- Large serving dishes
- Cooking gadgets

#### 🏕️ Outdoor
- Camping gear (tents, sleeping bags)
- Sports equipment (bikes, kayaks)
- Yard equipment (lawn mower, leaf blower)
- Grills, coolers
- Hiking gear

#### 🎮 Games
- Board games, card games
- Video game consoles
- Party games
- Outdoor games (cornhole, spikeball)
- Puzzle collections

### Filter UI
- **Horizontal scrollable chips** below app bar
- **"All" chip** selected by default (shows all categories)
- **Tap category** to filter to that category only
- **Active category** highlighted with brand color
- **Item count badge** on each category chip

### Multi-select (Future)
- Hold to multi-select categories
- Shows items from any selected category

</details>

<details>
<summary><b>Search & Sort</b></summary>

### Search Functionality
- **Search bar** in app bar
- **Search by**:
  - Item title
  - Description keywords
  - Owner username
- **Real-time search** (updates as you type)
- **Search history** (last 10 searches saved locally)
- **Clear search** button (X icon)

### Sort Options
- **Recently Added** (default) - newest first
- **Alphabetical** (A-Z by title)
- **By Owner** - group items by same owner
- **Distance** (future) - nearest items first

### Filter by Availability
- **Available only** (default)
- **On Loan** (to see what's popular)
- **All items** (available + on loan)

### Empty States
- **No items found** - "No items match your search"
- **No items in category** - "No Tools available yet. Be the first to share!"
- **Suggestions**: Show most popular categories or recent items

</details>

---

## Feature 3: Snap-to-List (Add Items)

<details>
<summary><b>Camera Integration</b></summary>

### Entry Points
- **Floating Action Button** (+) on main feed
- **"Add Item" button** in profile screen
- **Quick add** from empty state

### Camera Options
1. **Take Photo** - Opens camera viewfinder
2. **Choose from Gallery** - Opens photo picker
3. **Cancel** - Return to feed

### Camera Features
- **Grid overlay** for better composition
- **Flash control** (auto/on/off)
- **Flip camera** (front/rear)
- **Tap to focus**
- **Pinch to zoom**

### Photo Preview
- **Full screen preview** after capture
- **Retake button** - Go back to camera
- **Use Photo button** - Proceed to form
- **Crop/rotate tools** (optional)

### Technical Implementation
```dart
// Open camera
final XFile? photo = await ImagePicker().pickImage(
  source: ImageSource.camera,
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);

// Compress image
final compressedImage = await FlutterImageCompress.compressWithFile(
  photo.path,
  quality: 85,
  minWidth: 1920,
  minHeight: 1080,
);
```

</details>

<details>
<summary><b>Item Creation Form</b></summary>

### Form Fields

#### 1. Photo (Required)
- **Large preview** at top of form
- **Change photo** button overlaid
- **Image compression** indicator

#### 2. Title (Required)
- **Text field** (3-60 characters)
- **Placeholder**: "e.g., Cordless Drill"
- **Character counter** (60 max)
- **Validation**: Must be at least 3 chars

#### 3. Description (Optional)
- **Multiline text field** (0-500 characters)
- **Placeholder**: "Condition, special notes, accessories included..."
- **Character counter**
- **Helpful tips**: "Mention the condition and any special instructions"

#### 4. Category (Required)
- **4 large buttons** with icons
- **Visual selection** (one selected at a time)
- **Pre-selected based on AI suggestion** (future)

#### 5. Availability (Auto-set)
- **Defaults to "Available"**
- **Can be changed later** from item detail screen

### Form Validation
- **Real-time validation** as user types
- **Error messages** below fields
- **Disabled submit button** until valid
- **Success feedback** on submission

### Submit Actions
- **"Publish Item" button** (primary action)
- **"Save as Draft" button** (future) - Save without publishing
- **Loading state** during upload

### Image Upload Process
1. Compress image to < 2MB
2. Generate thumbnail (300x300)
3. Upload full image to `item-images/{userId}/{itemId}_full.jpg`
4. Upload thumbnail to `item-images/{userId}/{itemId}_thumb.jpg`
5. Save URLs to database
6. Show success message

### Technical Implementation
```dart
// Upload to Supabase Storage
final fullImagePath = '${userId}/${itemId}_full.jpg';
await supabase.storage.from('item-images').upload(
  fullImagePath,
  compressedImage,
);

// Get public URL
final imageUrl = supabase.storage
  .from('item-images')
  .getPublicUrl(fullImagePath);

// Save to database
await supabase.from('items').insert({
  'user_id': userId,
  'title': title,
  'description': description,
  'category': category,
  'image_url': imageUrl,
  'thumbnail_url': thumbnailUrl,
  'status': 'Available',
});
```

</details>

---

## Feature 4: Availability Toggle

<details>
<summary><b>Status Management</b></summary>

### Two Status States

#### ✅ Available
- **Meaning**: Item is ready to be borrowed
- **Visibility**: Appears in main feed
- **Color**: Green indicator
- **User can**: Receive borrow requests via chat

#### 🔒 On Loan
- **Meaning**: Item is currently borrowed by someone
- **Visibility**: Hidden from main feed (or grayed out with badge)
- **Color**: Red indicator
- **User can**: Track who borrowed it (future)

### Toggle Locations
- **Item detail screen** (owner only)
- **"My Items" list** (quick toggle on each item)
- **Swipe action** on My Items list

</details>

<details>
<summary><b>Toggle Controls</b></summary>

### Toggle UI (Item Detail)
- **Large switch widget** below item image
- **Label**: "Available to borrow"
- **ON** = Available (green), **OFF** = On Loan (red)
- **Only visible to item owner**
- **Confirmation dialog** when changing to "On Loan"

### Toggle UI (My Items List)
- **Inline switch** on right side of item card
- **Quick toggle** without opening detail
- **Visual feedback** (haptic vibration on change)
- **Status badge** updates immediately

### Confirmation Dialog (On Loan)
```
"Mark as On Loan?"

This will hide your item from the feed. 
You can mark it as Available again anytime.

[Cancel]  [Confirm]
```

### Technical Implementation
```dart
// Update status
await supabase
  .from('items')
  .update({'status': newStatus})
  .eq('id', itemId);

// Realtime update will notify all clients
```

</details>

<details>
<summary><b>Status History (Future)</b></summary>

### Track Status Changes
- **Create `item_status_history` table**
- **Log each status change** with timestamp
- **Show history** in item detail drawer
- **Calculate**: Times lent, average loan duration

### Borrower Tracking (Future)
- **Record who borrowed** (conversation_id link)
- **"Lent to @username"** label when On Loan
- **Return reminder** notification after X days

</details>

---

## Feature 5: In-App Chat System

<details>
<summary><b>Starting a Conversation</b></summary>

### Entry Points
- **"Ask to Borrow" button** on item detail screen
- **"Message Owner" button** on item card long-press

### Conversation Creation
1. User taps "Ask to Borrow"
2. Check if conversation already exists for this item + user pair
3. If exists, open existing conversation
4. If new:
   - Create new conversation record
   - Add both users as participants (borrower + owner)
   - Pre-populate first message (optional): "Hi, I'm interested in borrowing your {item_title}"
   - Navigate to chat screen

### Technical Implementation
```dart
// Check existing conversation
final existingConvo = await supabase
  .from('conversations')
  .select('id')
  .eq('item_id', itemId)
  .filter('conversation_participants.user_id', 'eq', currentUserId)
  .maybeSingle();

if (existingConvo != null) {
  // Open existing
  Navigator.push(ChatScreen(conversationId: existingConvo['id']));
} else {
  // Create new conversation
  final convo = await supabase.from('conversations').insert({
    'item_id': itemId,
  }).select().single();
  
  // Add participants
  await supabase.from('conversation_participants').insert([
    {'conversation_id': convo['id'], 'user_id': currentUserId},
    {'conversation_id': convo['id'], 'user_id': ownerId},
  ]);
  
  Navigator.push(ChatScreen(conversationId: convo['id']));
}
```

</details>

<details>
<summary><b>Chat Interface</b></summary>

### Layout (using flutter_chat_ui)
- **App bar**: Item title + thumbnail, owner avatar
- **Message list**: Scrollable chat bubbles
- **Input field**: Text input + send button at bottom

### Message Bubbles
- **Sent messages** (current user):
  - Aligned right
  - Brand color background
  - White text
- **Received messages** (other user):
  - Aligned left
  - Light gray background
  - Dark text
- **Sender avatar**: Only on received messages
- **Timestamp**: Below each message ("Just now", "5m ago", "Yesterday 3:45 PM")

### Input Field
- **Text input**: Multi-line (max 3 lines before scroll)
- **Send button**: Enabled only when text is non-empty
- **Character limit**: 1000 chars
- **Typing indicator** (future): "John is typing..."

### Real-time Message Delivery
- **Instant delivery** via Supabase Realtime
- **Optimistic UI updates** (show message immediately)
- **Delivery confirmation** (future): Double check mark
- **Read receipts** (future): Blue check mark when read

### Technical Implementation
```dart
// Subscribe to messages
final messagesStream = supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .eq('conversation_id', conversationId)
  .order('created_at');

// Send message
await supabase.from('messages').insert({
  'conversation_id': conversationId,
  'sender_id': currentUserId,
  'content': messageText,
});
```

</details>

<details>
<summary><b>Conversations List (Inbox)</b></summary>

### Access Point
- **Bottom navigation**: Chat/Messages tab
- **Badge indicator**: Shows total unread count

### Conversation Tiles
Each tile shows:
- **Item thumbnail** (left side)
- **Item title** (bold)
- **Other user's name** ("Chat with @username")
- **Last message preview** (1 line, truncated)
- **Timestamp** of last message
- **Unread badge** (red circle with count)

### Sorting
- **Most recent first** (by last_message_at)
- **Unread conversations** at top (future)

### Actions
- **Tap to open** chat screen
- **Swipe left**: Archive conversation (future)
- **Long press**: Delete conversation, Block user (future)

### Empty State
- **No conversations yet**
- **Illustration** of chat bubbles
- **Message**: "Your conversations will appear here. Start browsing items!"
- **Action button**: "Browse Items"

### Technical Implementation
```dart
// Fetch conversations with last message
final conversations = await supabase
  .from('conversations')
  .select('''
    *,
    item:items(*),
    participants:conversation_participants(user:profiles(*)),
    last_message:messages(content, created_at)
  ''')
  .filter('participants.user_id', 'eq', currentUserId)
  .order('last_message_at', ascending: false);
```

</details>

<details>
<summary><b>Privacy & Safety</b></summary>

### Privacy Features
- **No phone numbers shared** until users agree privately
- **No email addresses exposed** in app
- **Usernames only** for initial contact

### Safety Features (Future)
- **Block user**: Prevent further messages
- **Report conversation**: Flag inappropriate behavior
- **Auto-moderation**: Filter offensive language
- **Community guidelines**: Link in settings

### Data Retention
- **Messages stored permanently** (unless deleted)
- **User can delete**: Own messages only (marks as [Deleted])
- **Conversation deletion**: Both users must delete to remove from DB

</details>

---

## Feature Matrix

| Feature | Status | Priority | Complexity |
|---------|--------|----------|-----------|
| Email/Password Auth | ✅ MVP | High | Low |
| User Profiles | ✅ MVP | High | Medium |
| Item Feed | ✅ MVP | High | Medium |
| Category Filter | ✅ MVP | High | Low |
| Search Items | ✅ MVP | Medium | Medium |
| Snap-to-List | ✅ MVP | High | High |
| Availability Toggle | ✅ MVP | High | Low |
| In-App Chat | ✅ MVP | High | High |
| Real-time Updates | ✅ MVP | High | Medium |
| | | | |
| Profile Stats | 🔮 Phase 2 | Medium | Low |
| Push Notifications | 🔮 Phase 2 | High | High |
| Geolocation Filter | 🔮 Phase 2 | Medium | High |
| Ratings & Reviews | 🔮 Phase 2 | Medium | Medium |
| Borrower Tracking | 🔮 Phase 2 | Medium | Medium |
| Image Sharing in Chat | 🔮 Phase 2 | Low | Medium |
| Social Login | 🔮 Phase 3 | Low | Medium |
| In-App Payments | 🔮 Phase 3 | Low | High |

---

**Last Updated:** February 5, 2026
