import { createClient } from '@supabase/supabase-js';

// Supabase 환경 변수
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

// Supabase 클라이언트 생성
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
});

// 타입 정의
export type UserRole = 'super_admin' | 'branch_admin' | 'instructor' | 'student' | 'parent';
export type OrgType = 'headquarters' | 'branch';
export type ProgressStatus = 'not_started' | 'in_progress' | 'completed' | 'rewriting';
export type TransactionType = 'earned' | 'spent' | 'expired';
export type CurriculumStage = 'A' | 'B' | 'C' | 'D';

// Database 타입 정의
export interface Organization {
  id: string;
  name: string;
  type: OrgType;
  parent_id?: string;
  address?: string;
  phone?: string;
  settings?: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface Profile {
  id: string;
  email?: string;
  phone?: string;
  full_name?: string;
  role: UserRole;
  organization_id?: string;
  avatar_url?: string;
  metadata?: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface CurriculumWork {
  id: string;
  stage: CurriculumStage;
  sequence: number;
  title: string;
  author?: string;
  category?: string;
  difficulty?: number;
  description?: string;
  metadata?: Record<string, any>;
  created_at: string;
}

export interface Class {
  id: string;
  organization_id: string;
  name: string;
  instructor_id?: string;
  max_students?: number;
  current_students?: number;
  schedule?: Record<string, any>;
  is_active?: boolean;
  created_at: string;
  updated_at: string;
}

export interface StudentProgress {
  id: string;
  student_id: string;
  work_id: string;
  class_id?: string;
  week?: number;
  status: ProgressStatus;
  score?: number;
  started_at?: string;
  completed_at?: string;
  metadata?: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface MileageTransaction {
  id: string;
  user_id: string;
  type: TransactionType;
  category?: string;
  amount: number;
  balance: number;
  description?: string;
  metadata?: Record<string, any>;
  created_at: string;
}

export interface MileageBalance {
  user_id: string;
  total_earned: number;
  total_spent: number;
  current_balance: number;
  updated_at: string;
}

export interface Consultation {
  id: string;
  organization_id: string;
  student_name: string;
  parent_name: string;
  parent_phone: string;
  parent_email?: string;
  preferred_date?: string;
  preferred_time?: string;
  consultation_type?: string;
  notes?: string;
  status?: string;
  assigned_to?: string;
  created_at: string;
  updated_at: string;
}