-- Enable Row Level Security on all tables
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE curriculum_works ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE mileage_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE mileage_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE consultations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE revenue ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;

-- Helper function to get user role
CREATE OR REPLACE FUNCTION auth.role() 
RETURNS text 
LANGUAGE sql 
STABLE
AS $$
  SELECT COALESCE(
    (SELECT role::text FROM profiles WHERE id = auth.uid()),
    'student'
  );
$$;

-- Helper function to get user organization
CREATE OR REPLACE FUNCTION auth.organization_id() 
RETURNS uuid 
LANGUAGE sql 
STABLE
AS $$
  SELECT organization_id FROM profiles WHERE id = auth.uid();
$$;

-- Organizations policies
CREATE POLICY "Users can view their own organization" ON organizations
  FOR SELECT USING (
    id = auth.organization_id() OR
    auth.role() IN ('super_admin')
  );

CREATE POLICY "Only super admins can manage organizations" ON organizations
  FOR ALL USING (auth.role() = 'super_admin');

-- Profiles policies
CREATE POLICY "Users can view profiles in their organization" ON profiles
  FOR SELECT USING (
    organization_id = auth.organization_id() OR
    id = auth.uid() OR
    auth.role() = 'super_admin'
  );

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Admins can manage profiles in their organization" ON profiles
  FOR ALL USING (
    auth.role() IN ('super_admin', 'branch_admin') AND
    (organization_id = auth.organization_id() OR auth.role() = 'super_admin')
  );

-- Curriculum works policies (public read)
CREATE POLICY "Everyone can view curriculum" ON curriculum_works
  FOR SELECT USING (true);

CREATE POLICY "Only super admins can manage curriculum" ON curriculum_works
  FOR ALL USING (auth.role() = 'super_admin');

-- Classes policies
CREATE POLICY "Users can view classes in their organization" ON classes
  FOR SELECT USING (
    organization_id = auth.organization_id() OR
    auth.role() = 'super_admin'
  );

CREATE POLICY "Instructors can view their classes" ON classes
  FOR SELECT USING (
    instructor_id = auth.uid()
  );

CREATE POLICY "Admins can manage classes" ON classes
  FOR ALL USING (
    auth.role() IN ('super_admin', 'branch_admin') AND
    (organization_id = auth.organization_id() OR auth.role() = 'super_admin')
  );

-- Class enrollments policies
CREATE POLICY "Students can view their enrollments" ON class_enrollments
  FOR SELECT USING (
    student_id = auth.uid() OR
    auth.role() IN ('super_admin', 'branch_admin', 'instructor')
  );

CREATE POLICY "Admins and instructors can manage enrollments" ON class_enrollments
  FOR ALL USING (
    auth.role() IN ('super_admin', 'branch_admin', 'instructor')
  );

-- Student progress policies
CREATE POLICY "Students can view their own progress" ON student_progress
  FOR SELECT USING (
    student_id = auth.uid() OR
    auth.role() IN ('super_admin', 'branch_admin', 'instructor')
  );

CREATE POLICY "Instructors can manage student progress" ON student_progress
  FOR ALL USING (
    auth.role() IN ('super_admin', 'branch_admin', 'instructor')
  );

-- Assignments policies
CREATE POLICY "Users can view assignments for their classes" ON assignments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM class_enrollments ce
      WHERE ce.class_id = assignments.class_id
      AND (ce.student_id = auth.uid() OR auth.role() IN ('instructor', 'branch_admin', 'super_admin'))
    )
  );

CREATE POLICY "Instructors can manage assignments" ON assignments
  FOR ALL USING (
    auth.role() IN ('super_admin', 'branch_admin', 'instructor')
  );

-- Assignment submissions policies
CREATE POLICY "Students can view and submit their own submissions" ON assignment_submissions
  FOR ALL USING (
    student_id = auth.uid() OR
    auth.role() IN ('super_admin', 'branch_admin', 'instructor')
  );

-- Mileage transactions policies
CREATE POLICY "Users can view their own mileage" ON mileage_transactions
  FOR SELECT USING (
    user_id = auth.uid() OR
    auth.role() IN ('super_admin', 'branch_admin')
  );

CREATE POLICY "Only admins can manage mileage" ON mileage_transactions
  FOR ALL USING (
    auth.role() IN ('super_admin', 'branch_admin', 'instructor')
  );

-- Mileage balances policies
CREATE POLICY "Users can view their own balance" ON mileage_balances
  FOR SELECT USING (
    user_id = auth.uid() OR
    auth.role() IN ('super_admin', 'branch_admin', 'instructor')
  );

-- Consultations policies
CREATE POLICY "Admins can manage consultations" ON consultations
  FOR ALL USING (
    auth.role() IN ('super_admin', 'branch_admin') AND
    (organization_id = auth.organization_id() OR auth.role() = 'super_admin')
  );

-- Messages policies
CREATE POLICY "Users can view their own messages" ON messages
  FOR SELECT USING (
    recipient_id = auth.uid() OR
    auth.role() IN ('super_admin', 'branch_admin')
  );

CREATE POLICY "Admins can manage messages" ON messages
  FOR ALL USING (
    auth.role() IN ('super_admin', 'branch_admin')
  );

-- Revenue policies
CREATE POLICY "Admins can view revenue for their organization" ON revenue
  FOR SELECT USING (
    (organization_id = auth.organization_id() AND auth.role() IN ('branch_admin')) OR
    auth.role() = 'super_admin'
  );

CREATE POLICY "Only super admins can manage revenue" ON revenue
  FOR ALL USING (auth.role() = 'super_admin');

-- Feedbacks policies
CREATE POLICY "Students can view their feedbacks" ON feedbacks
  FOR SELECT USING (
    student_id = auth.uid() OR
    auth.role() IN ('super_admin', 'branch_admin', 'instructor')
  );

CREATE POLICY "Instructors can manage feedbacks" ON feedbacks
  FOR ALL USING (
    auth.role() IN ('super_admin', 'branch_admin', 'instructor')
  );