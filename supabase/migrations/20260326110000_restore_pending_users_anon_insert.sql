-- Restore the anon INSERT policy on pending_users that was dropped in
-- 20260315231209_fix_overpermissive_rls_policies.sql.
-- This policy is required for the public /employee/new onboarding form to work.
DROP POLICY IF EXISTS "Enable insert for anon users" ON public.pending_users;
CREATE POLICY "Enable insert for anon users" ON public.pending_users
FOR INSERT TO anon
WITH CHECK (true);
