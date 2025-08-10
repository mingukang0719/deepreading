-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create ENUM types
CREATE TYPE user_role AS ENUM ('super_admin', 'branch_admin', 'instructor', 'student', 'parent');
CREATE TYPE org_type AS ENUM ('headquarters', 'branch');
CREATE TYPE progress_status AS ENUM ('not_started', 'in_progress', 'completed', 'rewriting');
CREATE TYPE transaction_type AS ENUM ('earned', 'spent', 'expired');
CREATE TYPE curriculum_stage AS ENUM ('A', 'B', 'C', 'D');

-- Organizations table
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    type org_type NOT NULL,
    parent_id UUID REFERENCES organizations(id),
    address TEXT,
    phone VARCHAR(20),
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Profiles table (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    full_name VARCHAR(100),
    role user_role NOT NULL DEFAULT 'student',
    organization_id UUID REFERENCES organizations(id),
    avatar_url TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Curriculum works table (88 작품)
CREATE TABLE curriculum_works (
    id VARCHAR(10) PRIMARY KEY, -- e.g., 'A1', 'B17'
    stage curriculum_stage NOT NULL,
    sequence INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100),
    category VARCHAR(50),
    difficulty INT CHECK (difficulty BETWEEN 1 AND 5),
    description TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Classes table
CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) NOT NULL,
    name VARCHAR(100) NOT NULL,
    instructor_id UUID REFERENCES profiles(id),
    max_students INT DEFAULT 20,
    current_students INT DEFAULT 0,
    schedule JSONB, -- 수업 시간표
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Class enrollments (학생-반 연결)
CREATE TABLE class_enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID REFERENCES classes(id) NOT NULL,
    student_id UUID REFERENCES profiles(id) NOT NULL,
    enrolled_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(class_id, student_id)
);

-- Student progress tracking
CREATE TABLE student_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES profiles(id) NOT NULL,
    work_id VARCHAR(10) REFERENCES curriculum_works(id) NOT NULL,
    class_id UUID REFERENCES classes(id),
    week INT CHECK (week BETWEEN 1 AND 5),
    status progress_status DEFAULT 'not_started',
    score DECIMAL(5,2),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(student_id, work_id, week)
);

-- Assignments (과제)
CREATE TABLE assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID REFERENCES classes(id) NOT NULL,
    work_id VARCHAR(10) REFERENCES curriculum_works(id) NOT NULL,
    week INT CHECK (week BETWEEN 1 AND 5),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Assignment submissions
CREATE TABLE assignment_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id UUID REFERENCES assignments(id) NOT NULL,
    student_id UUID REFERENCES profiles(id) NOT NULL,
    content TEXT,
    file_url TEXT,
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    score DECIMAL(5,2),
    feedback TEXT,
    graded_at TIMESTAMPTZ,
    graded_by UUID REFERENCES profiles(id),
    UNIQUE(assignment_id, student_id)
);

-- Mileage system
CREATE TABLE mileage_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) NOT NULL,
    type transaction_type NOT NULL,
    category VARCHAR(50),
    amount INT NOT NULL,
    balance INT NOT NULL,
    description TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mileage balance view
CREATE TABLE mileage_balances (
    user_id UUID PRIMARY KEY REFERENCES profiles(id),
    total_earned INT DEFAULT 0,
    total_spent INT DEFAULT 0,
    current_balance INT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Consultations (상담)
CREATE TABLE consultations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    parent_name VARCHAR(100) NOT NULL,
    parent_phone VARCHAR(20) NOT NULL,
    parent_email VARCHAR(255),
    preferred_date DATE,
    preferred_time TIME,
    consultation_type VARCHAR(50),
    notes TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    assigned_to UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Messages (알림톡/SMS)
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_id UUID REFERENCES profiles(id),
    recipient_phone VARCHAR(20),
    message_type VARCHAR(50),
    content TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    sent_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Revenue data
CREATE TABLE revenue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
    amount DECIMAL(12,2) NOT NULL,
    student_count INT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, year, month)
);

-- Feedbacks
CREATE TABLE feedbacks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    submission_id UUID REFERENCES assignment_submissions(id),
    student_id UUID REFERENCES profiles(id) NOT NULL,
    instructor_id UUID REFERENCES profiles(id) NOT NULL,
    content TEXT NOT NULL,
    parent_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_profiles_organization ON profiles(organization_id);
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_student_progress_student ON student_progress(student_id);
CREATE INDEX idx_student_progress_status ON student_progress(status);
CREATE INDEX idx_mileage_user_created ON mileage_transactions(user_id, created_at DESC);
CREATE INDEX idx_classes_organization ON classes(organization_id);
CREATE INDEX idx_consultations_status ON consultations(status);
CREATE INDEX idx_revenue_org_date ON revenue(organization_id, year, month);

-- Row Level Security (RLS) policies will be added in next migration
-- Triggers for updated_at will be added in next migration