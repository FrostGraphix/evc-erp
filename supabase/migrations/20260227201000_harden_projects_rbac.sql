-- Harden project access to prevent unscoped read/write.
-- Inventory/purchasing table hardening is pending until those tables exist in DB.

create or replace function public.is_admin_like()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
  );
$$;

create or replace function public.is_project_member(project_uuid uuid, user_uuid uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.project_members pm
    where pm.project_id = project_uuid
      and pm.user_id = user_uuid
      and coalesce(pm.is_active, true)
  );
$$;

create or replace function public.can_manage_project(project_uuid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_admin_like()
    or exists (
      select 1
      from public.projects p
      where p.id = project_uuid
        and (
          p.created_by = auth.uid()
          or p.project_manager_id = auth.uid()
          or public.is_project_member(project_uuid, auth.uid())
        )
    );
$$;

create or replace function public.can_admin_project(project_uuid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_admin_like()
    or exists (
      select 1
      from public.projects p
      where p.id = project_uuid
        and (
          p.created_by = auth.uid()
          or p.project_manager_id = auth.uid()
        )
    );
$$;

grant execute on function public.is_admin_like() to authenticated;
grant execute on function public.is_project_member(uuid, uuid) to authenticated;
grant execute on function public.can_manage_project(uuid) to authenticated;
grant execute on function public.can_admin_project(uuid) to authenticated;

drop policy if exists "Projects management policy" on public.projects;
drop policy if exists "Projects select scoped" on public.projects;
drop policy if exists "Projects insert scoped" on public.projects;
drop policy if exists "Projects update scoped" on public.projects;
DROP POLICY IF EXISTS "Projects select scoped" ON public.projects;
CREATE POLICY "Projects select scoped" ON public.projects
for select
to authenticated
using (
  public.is_admin_like()
  or created_by = auth.uid()
  or project_manager_id = auth.uid()
  or public.is_project_member(id, auth.uid())
);

DROP POLICY IF EXISTS "Projects insert scoped" ON public.projects;
CREATE POLICY "Projects insert scoped" ON public.projects
for insert
to authenticated
with check (
  public.is_admin_like()
  or created_by = auth.uid()
  or project_manager_id = auth.uid()
);

DROP POLICY IF EXISTS "Projects update scoped" ON public.projects;
CREATE POLICY "Projects update scoped" ON public.projects
for update
to authenticated
using (
  public.can_manage_project(id)
)
with check (
  public.can_manage_project(id)
);

DROP POLICY IF EXISTS "Projects delete scoped" ON public.projects;
CREATE POLICY "Projects delete scoped" ON public.projects
for delete
to authenticated
using (
  public.can_admin_project(id)
);

drop policy if exists "Project members select policy" on public.project_members;
drop policy if exists "Project members insert policy" on public.project_members;
drop policy if exists "Project members update policy" on public.project_members;
DROP POLICY IF EXISTS "Project members select scoped" ON public.project_members;
CREATE POLICY "Project members select scoped" ON public.project_members
for select
to authenticated
using (
  public.can_manage_project(project_id)
);

DROP POLICY IF EXISTS "Project members insert scoped" ON public.project_members;
CREATE POLICY "Project members insert scoped" ON public.project_members
for insert
to authenticated
with check (
  public.can_admin_project(project_id)
);

DROP POLICY IF EXISTS "Project members update scoped" ON public.project_members;
CREATE POLICY "Project members update scoped" ON public.project_members
for update
to authenticated
using (
  public.can_admin_project(project_id)
)
with check (
  public.can_admin_project(project_id)
);

DROP POLICY IF EXISTS "Project members delete scoped" ON public.project_members;
CREATE POLICY "Project members delete scoped" ON public.project_members
for delete
to authenticated
using (
  public.can_admin_project(project_id)
);

drop policy if exists "Project items select policy" on public.project_items;
drop policy if exists "Project items insert policy" on public.project_items;
drop policy if exists "Project items update policy" on public.project_items;
DROP POLICY IF EXISTS "Project items select scoped" ON public.project_items;
CREATE POLICY "Project items select scoped" ON public.project_items
for select
to authenticated
using (
  public.can_manage_project(project_id)
);

DROP POLICY IF EXISTS "Project items insert scoped" ON public.project_items;
CREATE POLICY "Project items insert scoped" ON public.project_items
for insert
to authenticated
with check (
  public.can_manage_project(project_id)
);

DROP POLICY IF EXISTS "Project items update scoped" ON public.project_items;
CREATE POLICY "Project items update scoped" ON public.project_items
for update
to authenticated
using (
  public.can_manage_project(project_id)
)
with check (
  public.can_manage_project(project_id)
);

DROP POLICY IF EXISTS "Project items delete scoped" ON public.project_items;
CREATE POLICY "Project items delete scoped" ON public.project_items
for delete
to authenticated
using (
  public.can_admin_project(project_id)
);
