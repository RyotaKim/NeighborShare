# App Flow & User Journeys - NeighborShare

## Overview
Complete user journeys and interaction flows for different user types in the NeighborShare app.

---

## First-Time User Journey

<details>
<summary><b>Onboarding Flow (New User)</b></summary>

### Step-by-Step Journey

**1. App Launch**
- Splash screen with NeighborShare logo
- Loading animation (2-3 seconds)
- Automatic navigation to welcome screen

**2. Welcome Screen**
- Hero image/illustration of community sharing
- Tagline: "Borrow what you need. Share what you have."
- Two primary buttons:
  - **Sign Up** (prominent)
  - **Log In** (secondary)
- Skip tutorial link (goes directly to login)

**3. Sign Up Screen**
- Form fields:
  - Email address
  - Password (with show/hide toggle)
  - Confirm password
- Real-time validation indicators
- Password strength meter
- Terms of Service checkbox
- **Create Account** button
- "Already have an account? Log In" link

**4. Email Verification**
- Success message: "Check your email!"
- Instructions to click verification link
- Resend email button (30-second cooldown)
- Can't proceed until verified

**5. Verification Success**
- Email link opens app
- "Email verified!" success message
- Auto-navigate to Profile Setup

**6. Profile Setup Screen**
- Progress indicator: "Step 1 of 2"
- Avatar picker:
  - Placeholder with camera icon
  - Tap to take photo or choose from gallery
  - Optional (can skip)
- Username field:
  - Real-time availability check
  - Green checkmark when available
  - Min 3 chars, alphanumeric + underscore
- Full name field (optional)
- **Continue** button

**7. Neighborhood Selection**
- Progress indicator: "Step 2 of 2"
- Text field: "Enter your neighborhood"
- Suggestions dropdown based on input
- Location permission request (optional)
- Auto-detect neighborhood from GPS
- **Finish Setup** button

**8. Tutorial Overlay**
- Semi-transparent overlay on Home Feed
- 4 quick tips with arrows:
  1. "Browse items from your neighbors"
  2. "Filter by category"
  3. "Tap + to add your own items"
  4. "Chat with owners to borrow"
- **Got It** button to dismiss
- "Don't show again" checkbox

**9. Home Feed (First View)**
- Empty state if no items in neighborhood yet
- Message: "Be the first to share!"
- **Add Your First Item** button
- Or browse all items (toggle to show all neighborhoods)

### Timeline
- Total: ~5-8 minutes for complete onboarding
- Can be paused and resumed at any step

</details>

<details>
<summary><b>Returning User Flow</b></summary>

**1. App Launch**
- Splash screen (1-2 seconds)
- Auto-login with saved session (JWT token)
- No interaction required

**2. Direct to Home Feed**
- Last viewed category filter applied
- Scroll position restored (if recent)
- New items badge if items added since last visit

**3. Biometric Login (Future)**
- Prompt for fingerprint/face ID
- Fallback to password if failed
- Remember device option

</details>

---

## Borrower Journey

<details>
<summary><b>Complete Borrowing Flow</b></summary>

### Scenario: User wants to borrow a drill

**1. Open App**
- Auto-login with saved JWT token
- Lands on Home Feed (Item Feed Screen)
- Sees grid of available items in neighborhood

**2. Browse & Filter**
- Scroll through feed
- Notice "Tools" category might have what they need
- Tap **"Tools"** chip in category filter bar
- Feed updates to show only Tools

**3. Find Desired Item**
- Scroll through tools
- See "Cordless Drill - DeWalt 20V"
- Item card shows:
  - Photo of drill
  - Title
  - "Tools" badge
  - Green "Available" indicator
  - Owner: "@john_doe"
- Tap on card to view details

**4. View Item Details**
- Full-screen photo (swipe for more if multiple)
- Title: "Cordless Drill - DeWalt 20V"
- Description: "Barely used, includes battery and charger. Great for home projects!"
- Category: Tools
- Status: ✅ Available
- Owner info:
  - Avatar
  - Username: "@john_doe"
  - Neighborhood: "Downtown"
  - Items shared: 5
- **Ask to Borrow** button (prominent)
- **View Owner's Other Items** link

**5. Initiate Conversation**
- Tap **"Ask to Borrow"** button
- Check for existing conversation
  - If exists: Open that conversation
  - If new: Create conversation + navigate to chat

**6. Chat Screen Opens**
- App bar shows:
  - Item thumbnail (small)
  - Item title
  - Owner avatar
- Empty conversation (first message)
- Pre-filled suggestion (optional): "Hi! I'd like to borrow your Cordless Drill. Is it still available?"
- Type custom message: "Hi John! Could I borrow this tomorrow afternoon? I need it for a quick project."

**7. Send Message**
- Tap send button
- Message appears in chat with timestamp
- Optimistic UI (shows immediately)
- Delivery confirmation (checkmark)

**8. Wait for Response**
- Push notification when owner replies (future)
- Real-time message delivery
- Owner responds: "Sure! What time works for you?"

**9. Coordinate Pickup**
- Back-and-forth conversation:
  - Borrower: "How about 2 PM?"
  - Owner: "Perfect! Meet at 123 Main St?"
  - Borrower: "Great, see you then!"
- Both users have pickup details

**10. Meet Owner (Outside App)**
- Meet at agreed location
- Owner hands over drill + instructions
- Discuss return date/time
- Owner marks item as "On Loan" in app

**11. Item Status Updated**
- Owner toggles availability to **"On Loan"**
- Item disappears from main feed (or grayed out)
- Borrower can see status in chat

**12. Use Item**
- Borrower uses drill for project
- Item is off-market during this time

**13. Arrange Return**
- Chat message: "Hi John, finished my project! Can I return it tomorrow?"
- Owner: "Sure, same time and place?"
- Agreement reached

**14. Return Item**
- Meet at location
- Hand back drill
- Owner inspects condition
- Thank borrower

**15. Update Status**
- Owner toggles back to **"Available"**
- Item reappears in feed for others

**16. Leave Feedback (Future)**
- Borrower rates experience (5 stars)
- Optional comment: "Great tool, John was very helpful!"
- Rating visible on owner's profile

### Key Touchpoints
- Browse → Discover → Inquire → Coordinate → Borrow → Return
- Total time in app: ~5-10 minutes (excluding waiting for responses)

</details>

<details>
<summary><b>Alternative Borrower Flows</b></summary>

### Scenario: Item Already On Loan

**User Journey:**
1. Find item in feed
2. Tap to view details
3. See status: 🔒 **On Loan**
4. Options:
   - **Ask When Available** button (future) - Gets notified when available
   - Browse similar items
   - Go back to feed

---

### Scenario: Search for Specific Item

**User Journey:**
1. Open app → Home Feed
2. Tap search icon in app bar
3. Type: "ladder"
4. Results filtered in real-time
5. See "Extension Ladder 24ft" in results
6. Proceed to view details → chat flow

---

### Scenario: Browse Owner's Other Items

**User Journey:**
1. Viewing item detail screen
2. Tap **"View Owner's Other Items"**
3. Navigate to owner's profile
4. See list of all their items
5. Tap another item to view
6. Can start new conversation about different item

</details>

---

## Lender Journey

<details>
<summary><b>Complete Lending Flow</b></summary>

### Scenario: User wants to share their ladder

**1. Open App**
- Auto-login
- Lands on Home Feed

**2. Decide to Add Item**
- Notice the **Floating Action Button** (+) at bottom-right
- Tap **+** button
- Options appear:
  - **Take Photo**
  - **Choose from Gallery**
  - Cancel

**3. Take Photo**
- Select **"Take Photo"**
- Camera opens with:
  - Grid overlay for composition
  - Flash control
  - Flip camera button
- Position ladder in frame
- Tap capture button
- Photo preview shows
- Options:
  - **Retake** (go back to camera)
  - **Use Photo** (proceed to form)

**4. Fill Item Details Form**
- Large image preview at top
- **Title field** (required):
  - Type: "Extension Ladder 24ft"
  - Character counter: 21/60
- **Description field** (optional):
  - Type: "Aluminum extension ladder, can reach up to 24 feet. Great condition, only used a few times. Includes safety feet."
  - Character counter: 145/500
- **Category selection** (required):
  - Four large buttons with icons
  - Select: **🔧 Tools** (highlighted)
- **Availability** (auto-set):
  - Defaults to ✅ **Available**
  - Info text: "You can change this later"

**5. Publish Item**
- Review all fields
- Validation passes (title + category filled)
- Tap **"Publish Item"** button
- Loading indicator appears
- Backend process:
  1. Compress image
  2. Generate thumbnail
  3. Upload to Supabase Storage
  4. Save item to database
- Success message: "Item published!"
- Auto-navigate back to Home Feed

**6. Item Appears in Feed**
- Ladder item now visible at top of feed
- Real-time update for all users in neighborhood
- Owner sees "My Item" badge on their own item

**7. Receive Borrow Request**
- Push notification: "Sarah wants to borrow your Extension Ladder" (future)
- Badge on Chat tab (unread count)
- Open Chat tab

**8. Conversations Screen (Inbox)**
- See new conversation:
  - Ladder thumbnail
  - "Extension Ladder 24ft"
  - "Chat with @sarah_smith"
  - Preview: "Hi! Could I borrow this for..."
  - Timestamp: "2 min ago"
  - Unread badge (red dot)
- Tap conversation to open

**9. Chat Screen Opens**
- See Sarah's message: "Hi! Could I borrow this for the weekend? I need to clean my gutters."
- Owner's response options:
  - Type custom reply
  - Quick replies (future): "Yes, available", "When do you need it?", "Sorry, it's on loan"

**10. Coordinate Lending**
- Owner: "Sure! When do you need it?"
- Sarah: "Could I pick it up Saturday morning?"
- Owner: "Works for me! How about 10 AM at 123 Main St?"
- Sarah: "Perfect, see you then!"

**11. Meet Borrower (Outside App)**
- Sarah arrives at 10 AM
- Owner demonstrates ladder safety
- Hands over ladder
- Discuss return date: "Please return by Monday evening"

**12. Update Item Status**
- Owner opens app
- Options:
  - **Option A**: From Chat Screen
    - Tap item thumbnail in app bar
    - Opens Item Detail
    - Toggle availability switch to **On Loan**
  - **Option B**: From Home Feed
    - Tap on their ladder item
    - Toggle to **On Loan**
  - **Option C**: From Profile → My Items
    - Swipe on ladder item
    - Quick toggle switch
- Confirmation dialog: "Mark as On Loan? This will hide it from the feed."
- Tap **Confirm**
- Status updated immediately
- Real-time update: Item removed from feed for all users

**13. Track Loan (Current State)**
- Item shows as "On Loan" in My Items list
- Can still view item details
- Can message Sarah via existing chat

**14. Receive Return Request**
- Monday morning: Sarah messages "Hi! Can I return the ladder this evening?"
- Owner: "Sure, 7 PM work?"
- Agreement reached

**15. Item Returned**
- Sarah returns ladder
- Owner inspects (all good!)
- Thanks Sarah

**16. Mark Available Again**
- Owner toggles status back to **Available**
- Item reappears in feed for others
- Ready to lend again

**17. View Lending History (Future)**
- Owner can see:
  - Times lent: 3
  - Average loan duration: 2 days
  - Rating: 5 stars
  - Comments from borrowers

### Key Touchpoints
- Add → Publish → Receive Request → Coordinate → Lend → Track → Return → Re-list
- Total time in app: ~5 minutes (initial listing) + ~5 minutes (status updates)

</details>

<details>
<summary><b>Alternative Lender Flows</b></summary>

### Scenario: Edit Item Details

**User Journey:**
1. Profile → My Items
2. Tap on item to view details
3. Tap **Edit** button (pencil icon)
4. Update description or title
5. **Save Changes**
6. Real-time update across all views

---

### Scenario: Delete Item

**User Journey:**
1. Profile → My Items
2. Long-press on item (or swipe left)
3. **Delete** option appears
4. Confirmation dialog: "Delete Extension Ladder? This cannot be undone."
5. Tap **Delete**
6. Item removed from database
7. Image deleted from storage

---

### Scenario: Multiple Borrow Requests

**User Journey:**
1. Two users message about same item
2. Inbox shows 2 conversations for same item
3. Owner responds to first requester
4. Marks item as **On Loan**
5. Second requester sees status updated in real-time
6. Owner can reply: "Sorry, it's currently on loan. I'll let you know when it's back!"

</details>

---

## Quick Action Flows

<details>
<summary><b>View Own Profile</b></summary>

1. Tap **Profile** tab in bottom nav
2. See profile header:
   - Avatar
   - Username
   - Full name
   - Neighborhood
   - Member since date
3. Stats section:
   - Items listed: 5
   - Available now: 3
   - Times lent: 12
4. **My Items** section (grid view)
5. **Edit Profile** button
6. **Settings** button
7. **Logout** button

</details>

<details>
<summary><b>View Another User's Profile</b></summary>

1. From item detail screen, tap owner's avatar
2. Navigate to their profile (view-only)
3. See:
   - Avatar + username
   - Neighborhood
   - Items shared count
4. Grid of their items
5. Tap item to view details
6. **Back** button to previous screen

</details>

<details>
<summary><b>Search for Item</b></summary>

1. Home Feed → Tap search icon
2. Search bar expands
3. Type query: "drill"
4. Results update in real-time
5. Tap result to view details
6. Clear search to return to full feed

</details>

<details>
<summary><b>Change Neighborhood Filter (Future)</b></summary>

1. Home Feed → Tap neighborhood name in app bar
2. Dropdown menu opens
3. Options:
   - My Neighborhood (default)
   - Nearby (5 mile radius)
   - All Neighborhoods
4. Select option
5. Feed updates with items from selected area

</details>

---

## Error & Edge Case Flows

<details>
<summary><b>Network Connection Lost</b></summary>

**During Browsing:**
- Last fetched items remain visible
- Banner at top: "No internet connection"
- Pull-to-refresh disabled
- Tap item: "Cannot load details. Check your connection."

**During Image Upload:**
- Loading indicator stops
- Error message: "Upload failed. Check your internet connection."
- **Retry** button
- **Save Draft** option (saves locally, uploads when online)

**During Chat:**
- Message stuck in "Sending..." state
- Retry automatically when connection restored
- Show warning: "Messages will send when you're back online"

</details>

<details>
<summary><b>Item Deleted While Viewing</b></summary>

1. User viewing item detail screen
2. Owner deletes item from another device
3. Real-time update triggers
4. Snackbar appears: "This item is no longer available"
5. Auto-navigate back to Home Feed after 2 seconds

</details>

<details>
<summary><b>Account Verification Required</b></summary>

1. User signs up
2. Skips email verification
3. Tries to add item
4. Blocked with message: "Please verify your email first"
5. **Resend Verification Email** button
6. Check email → Verify → Can now add items

</details>

<details>
<summary><b>Chat with Deleted User</b></summary>

1. Conversation exists with another user
2. That user deletes their account
3. Chat shows: "[User Deleted]" in place of username
4. Can still view message history (read-only)
5. Cannot send new messages
6. Option to **Archive Conversation**

</details>

---

## Flow Diagrams (Text-Based)

### Item Borrowing Flow
```
[Home Feed] 
    ↓ tap item
[Item Detail]
    ↓ tap "Ask to Borrow"
[Chat Screen]
    ↓ coordinate pickup
[Meet Owner]
    ↓ receive item
[Owner marks On Loan]
    ↓ use item
[Coordinate Return]
    ↓ return item
[Owner marks Available]
```

### Item Adding Flow
```
[Home Feed]
    ↓ tap +
[Camera/Gallery]
    ↓ capture photo
[Photo Preview]
    ↓ confirm
[Item Form]
    ↓ fill details
[Validate]
    ↓ submit
[Upload Images]
    ↓
[Save to Database]
    ↓
[Success → Back to Feed]
```

### Authentication Flow
```
[Welcome Screen]
    ↓ Sign Up
[Register Form]
    ↓ submit
[Email Sent]
    ↓ verify link
[Email Verified]
    ↓
[Profile Setup]
    ↓
[Neighborhood Selection]
    ↓
[Tutorial]
    ↓
[Home Feed]
```

---

**Last Updated:** February 5, 2026
