-- ============================================================
-- EVC ERP: Initial Seed Data for Local & Remote PostgreSQL
-- Creates default Super Admin, HR, IT, Department Lead & Staff
-- Default password: Password123!
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DO $$
DECLARE
  v_admin_id UUID := '00000000-0000-0000-0000-000000000001';
  v_hr_id    UUID := '00000000-0000-0000-0000-000000000002';
  v_it_id    UUID := '00000000-0000-0000-0000-000000000003';
  v_lead_id  UUID := '00000000-0000-0000-0000-000000000004';
  v_staff_id UUID := '00000000-0000-0000-0000-000000000005';
  v_encrypted_password TEXT := crypt('Password123!', gen_salt('bf'));
BEGIN
  -- 1. Insert into auth.users (if using Supabase Auth schema)
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'users') THEN

    -- Super Admin (MD)
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at
    ) VALUES (
      v_admin_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
      'admin@evcng.com', v_encrypted_password, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"first_name":"Danmusa","last_name":"Abdulsamad","full_name":"Danmusa Abdulsamad"}'::jsonb,
      now(), now()
    ) ON CONFLICT (id) DO UPDATE SET encrypted_password = EXCLUDED.encrypted_password;

    -- HR Admin
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at
    ) VALUES (
      v_hr_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
      'hr@evcng.com', v_encrypted_password, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"first_name":"Amina","last_name":"Bello","full_name":"Amina Bello"}'::jsonb,
      now(), now()
    ) ON CONFLICT (id) DO UPDATE SET encrypted_password = EXCLUDED.encrypted_password;

    -- IT / Developer
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at
    ) VALUES (
      v_it_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
      'it@evcng.com', v_encrypted_password, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"first_name":"Tunde","last_name":"Okafor","full_name":"Tunde Okafor"}'::jsonb,
      now(), now()
    ) ON CONFLICT (id) DO UPDATE SET encrypted_password = EXCLUDED.encrypted_password;

    -- Department Lead
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at
    ) VALUES (
      v_lead_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
      'lead@evcng.com', v_encrypted_password, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"first_name":"Fatima","last_name":"Garba","full_name":"Fatima Garba"}'::jsonb,
      now(), now()
    ) ON CONFLICT (id) DO UPDATE SET encrypted_password = EXCLUDED.encrypted_password;

    -- Staff Member
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at
    ) VALUES (
      v_staff_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
      'staff@evcng.com', v_encrypted_password, now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"first_name":"Blessing","last_name":"Funsho","full_name":"Blessing Funsho"}'::jsonb,
      now(), now()
    ) ON CONFLICT (id) DO UPDATE SET encrypted_password = EXCLUDED.encrypted_password;

  END IF;

  -- 2. Upsert into public.profiles
  INSERT INTO public.profiles (
    id, company_email, first_name, last_name, employee_number, department, designation,
    role, is_admin, admin_routes, is_department_lead, lead_departments, employment_status, gender
  ) VALUES
  (
    v_admin_id, 'admin@evcng.com', 'Danmusa', 'Abdulsamad', 'EVC/2026/001', 'Executive Management', 'Managing Director',
    'super_admin', true, ARRAY['accounts', 'assets', 'audit-logs', 'communications', 'corporate-services', 'documentation', 'employees', 'feedback', 'hr', 'inventory', 'it', 'job-descriptions', 'md-desk', 'notification', 'payments', 'payroll', 'pms', 'projects', 'reports', 'security', 'settings', 'tasks'],
    true, ARRAY['Executive Management'], 'active', 'male'
  ),
  (
    v_hr_id, 'hr@evcng.com', 'Amina', 'Bello', 'EVC/2026/002', 'Admin & HR', 'HR Manager',
    'admin', true, ARRAY['hr', 'employees', 'job-descriptions', 'reports', 'settings'],
    true, ARRAY['Admin & HR'], 'active', 'female'
  ),
  (
    v_it_id, 'it@evcng.com', 'Tunde', 'Okafor', 'EVC/2026/003', 'IT and Communications', 'Lead Systems Engineer',
    'developer', true, ARRAY['it', 'security', 'audit-logs', 'settings'],
    true, ARRAY['IT and Communications'], 'active', 'male'
  ),
  (
    v_lead_id, 'lead@evcng.com', 'Fatima', 'Garba', 'EVC/2026/004', 'Operations', 'Operations Lead',
    'employee', false, ARRAY[]::text[],
    true, ARRAY['Operations'], 'active', 'female'
  ),
  (
    v_staff_id, 'staff@evcng.com', 'Blessing', 'Funsho', 'EVC/2026/005', 'Corporate Services', 'Project Associate',
    'employee', false, ARRAY[]::text[],
    false, ARRAY[]::text[], 'active', 'female'
  )
  ON CONFLICT (id) DO UPDATE SET
    company_email = EXCLUDED.company_email,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    role = EXCLUDED.role,
    is_admin = EXCLUDED.is_admin,
    admin_routes = EXCLUDED.admin_routes,
    is_department_lead = EXCLUDED.is_department_lead,
    lead_departments = EXCLUDED.lead_departments,
    department = EXCLUDED.department,
    designation = EXCLUDED.designation,
    employment_status = EXCLUDED.employment_status,
    gender = EXCLUDED.gender;

END $$;
