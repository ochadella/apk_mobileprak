-- Jalankan SQL ini di Supabase Dashboard > SQL Editor

-- 1. TABLE: profiles (extends auth.users dengan role)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('Admin', 'Helpdesk', 'User')) DEFAULT 'User',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 2. TABLE: tickets
CREATE TABLE tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  priority TEXT NOT NULL CHECK (priority IN ('Rendah', 'Sedang', 'Tinggi', 'Urgent')) DEFAULT 'Sedang',
  status TEXT NOT NULL CHECK (status IN ('Open', 'Assigned', 'In Progress', 'Closed')) DEFAULT 'Open',
  reporter_id UUID REFERENCES profiles(id) NOT NULL,
  assignee_id UUID REFERENCES profiles(id),
  attachment_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

-- 3. TABLE: ticket_comments
CREATE TABLE ticket_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID REFERENCES tickets(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE ticket_comments ENABLE ROW LEVEL SECURITY;

-- 4. TABLE: ticket_tracking (history perubahan status)
CREATE TABLE ticket_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID REFERENCES tickets(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL,
  note TEXT,
  changed_by UUID REFERENCES profiles(id) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE ticket_tracking ENABLE ROW LEVEL SECURITY;

-- 5. SEED: default admin user (password: admin123)
-- Pertama daftar dulu lewat app, nanti otomatis masuk

-- 6. RLS POLICIES: profiles
CREATE POLICY "Users can view all profiles"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- 7. RLS POLICIES: tickets
CREATE POLICY "Users can view their own tickets"
  ON tickets FOR SELECT
  USING (
    reporter_id = auth.uid()
    OR assignee_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('Admin', 'Helpdesk')
    )
  );

CREATE POLICY "Users can create tickets"
  ON tickets FOR INSERT
  WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "Helpdesk and Admin can update tickets"
  ON tickets FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('Admin', 'Helpdesk')
    )
    OR reporter_id = auth.uid()
  );

-- 8. RLS POLICIES: ticket_comments
CREATE POLICY "Users can view comments on visible tickets"
  ON ticket_comments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM tickets t
      WHERE t.id = ticket_id
      AND (
        t.reporter_id = auth.uid()
        OR t.assignee_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM profiles
          WHERE id = auth.uid() AND role IN ('Admin', 'Helpdesk')
        )
      )
    )
  );

CREATE POLICY "Users can create comments on visible tickets"
  ON ticket_comments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM tickets t
      WHERE t.id = ticket_id
      AND (
        t.reporter_id = auth.uid()
        OR t.assignee_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM profiles
          WHERE id = auth.uid() AND role IN ('Admin', 'Helpdesk')
        )
      )
    )
  );

-- 9. RLS POLICIES: ticket_tracking
CREATE POLICY "Users can view tracking on visible tickets"
  ON ticket_tracking FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM tickets t
      WHERE t.id = ticket_id
      AND (
        t.reporter_id = auth.uid()
        OR t.assignee_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM profiles
          WHERE id = auth.uid() AND role IN ('Admin', 'Helpdesk')
        )
      )
    )
  );

CREATE POLICY "System can insert tracking"
  ON ticket_tracking FOR INSERT
  WITH CHECK (true);

-- 10. TRIGGER: auto-update updated_at on tickets
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tickets_updated_at
  BEFORE UPDATE ON tickets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
