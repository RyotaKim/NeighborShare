-- ============================================
-- NeighborShare Database Setup Script
-- Run this in Supabase SQL Editor
-- Project: https://iyballqoxboxmqytyhrc.supabase.co
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

-- ============================================
-- Setup Complete! 
-- Next: Create Storage Buckets via Supabase Dashboard
-- ============================================
