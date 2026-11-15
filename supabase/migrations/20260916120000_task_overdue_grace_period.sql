-- Nightly job + app code flag tasks whose deadline has passed: the lead has
-- a grace period (configured via app_settings or default 24h) to either extend
-- the deadline or mark the work unable to complete before the task is recorded
-- as failed.
--
-- This migration:
-- 1. Adds 'task_overdue' to public.notifications.type CHECK so the reminder
--    inserts do not fail.
-- 2. Adds tasks.grace_period_ends_at so the UI can show the countdown and the
--    job knows when to flip the status.

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS grace_period_ends_at timestamptz;

COMMENT ON COLUMN public.tasks.grace_period_ends_at IS
  'When the post-deadline grace period expires. NULL while pending/completed/cancelled.';

CREATE INDEX IF NOT EXISTS idx_tasks_grace_period_active
  ON public.tasks (grace_period_ends_at)
  WHERE grace_period_ends_at IS NOT NULL;

-- Notification types for the project-manager reminders:
-- deadlines approaching, submitted work waiting on a decision, approved work
-- still unrated, and projects slipping behind, plus task_overdue.
--
-- The constraint is replaced wholesale rather than appended to, so the full
-- existing list is restated here.

ALTER TABLE public.notifications
DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE public.notifications
ADD CONSTRAINT notifications_type_check
CHECK (
  type = ANY (
    ARRAY[
      -- Existing legacy/system types
      'token_generated',
      'token_cancelled',
      'task_completed',
      'task_failed',
      'customer_added',
      'customer_updated',
      'meter_status_change',
      'meter_added',
      'activity_reminder',
      'crm_contact_added',
      'opportunity_won',
      'opportunity_lost',
      'system_alert',
      'asset_assigned',
      'asset_transfer_outgoing',
      'asset_transfer_incoming',
      'asset_returned',
      'asset_status_alert',
      'asset_status_fixed',
      'system_restored',
      -- App notification types
      'task_assigned',
      'task_updated',
      'task_created',
      'task_deleted',
      'task_approved',
      'task_rejected',
      'task_review_requested',
      'department_created',
      'department_updated',
      'department_deleted',
      'mention',
      'feedback',
      'approval_request',
      'approval_granted',
      'approval_rejected',
      'announcement',
      'system',
      -- Project/task governance reminders
      'task_due_soon',
      'task_awaiting_review',
      'task_needs_rating',
      'project_delayed',
      'task_blocked',
      -- Deadline passed, grace period running: extend it or mark it unable to
      -- complete before the nightly job records it as failed.
      'task_overdue'
    ]::text[]
  )
);

NOTIFY pgrst, 'reload schema';
