-- Core Tables Base Migration
-- Creates all core tables with IF NOT EXISTS so subsequent migrations can add/alter columns and policies safely.


DO $do$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'employment_status') THEN
    CREATE TYPE "public"."employment_status" AS ENUM ('active', 'suspended', 'terminated', 'on_leave');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'gateway_status') THEN
    CREATE TYPE "public"."gateway_status" AS ENUM ('online', 'offline', 'maintenance');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'task_priority') THEN
    CREATE TYPE "public"."task_priority" AS ENUM ('low', 'medium', 'high', 'critical');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE "public"."user_role" AS ENUM ('visitor', 'employee', 'lead', 'admin', 'super_admin');
  END IF;
END $do$;


CREATE TABLE IF NOT EXISTS "public"."admin_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "admin_id" "uuid" NOT NULL,
    "action" "text" NOT NULL,
    "target_user_id" "uuid",
    "changes" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."applications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "job_posting_id" "uuid" NOT NULL,
    "applicant_name" character varying(200) NOT NULL,
    "applicant_email" character varying(255) NOT NULL,
    "applicant_phone" character varying(50),
    "resume_url" "text",
    "cover_letter" "text",
    "status" character varying(20) DEFAULT 'applied'::character varying,
    "source" character varying(50),
    "applied_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."asset_assignments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "asset_id" "uuid",
    "assigned_to" "uuid",
    "assigned_from" "uuid",
    "assigned_by" "uuid",
    "assigned_at" timestamp with time zone DEFAULT "now"(),
    "handed_over_at" timestamp with time zone,
    "assignment_notes" "text",
    "handover_notes" "text",
    "is_current" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "department" "text",
    "assignment_type" "text" DEFAULT 'individual'::"text",
    "office_location" "text",
    CONSTRAINT "asset_assignments_assignment_type_check" CHECK ((("assignment_type" IS NULL) OR ("assignment_type" = ANY (ARRAY['individual'::"text", 'department'::"text", 'office'::"text"]))))
);


CREATE TABLE IF NOT EXISTS "public"."asset_issues" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "asset_id" "uuid" NOT NULL,
    "description" "text" NOT NULL,
    "resolved" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "resolved_at" timestamp with time zone,
    "resolved_by" "uuid",
    "created_by" "uuid" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."asset_types" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "label" "text" NOT NULL,
    "code" "text" NOT NULL,
    "requires_serial_model" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid"
);


CREATE TABLE IF NOT EXISTS "public"."assets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "asset_name" "text",
    "asset_type" "text" NOT NULL,
    "asset_model" "text",
    "serial_number" "text",
    "notes" "text",
    "status" "text" DEFAULT 'available'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "assignment_type" "text",
    "department" "text",
    "unique_code" "text" NOT NULL,
    "acquisition_year" integer,
    "office_location" "text",
    CONSTRAINT "assets_assignment_type_check" CHECK ((("assignment_type" IS NULL) OR ("assignment_type" = ANY (ARRAY['individual'::"text", 'department'::"text", 'office'::"text"])))),
    CONSTRAINT "assets_department_check" CHECK ((("department" IS NULL) OR ("department" = ANY (ARRAY['Accounts'::"text", 'Admin & HR'::"text", 'Business, Growth and Innovation'::"text", 'IT and Communications'::"text", 'Legal, Regulatory and Compliance'::"text", 'Logistics'::"text", 'Operations'::"text", 'Technical'::"text"])))),
    CONSTRAINT "assets_office_location_check" CHECK ((("office_location" IS NULL) OR ("office_location" = ANY (ARRAY['Accounts'::"text", 'Admin & HR'::"text", 'Assistant Executive Director'::"text", 'Business, Growth and Innovation'::"text", 'General Conference Room'::"text", 'IT and Communications'::"text", 'Kitchen'::"text", 'Legal, Regulatory and Compliance'::"text", 'MD Conference Room'::"text", 'MD Office'::"text", 'Operations'::"text", 'Reception'::"text", 'Site'::"text", 'Technical'::"text", 'Technical Extension'::"text"]))))
);


CREATE TABLE IF NOT EXISTS "public"."attendance_records" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "date" "date" NOT NULL,
    "clock_in" time without time zone,
    "clock_out" time without time zone,
    "break_duration" integer DEFAULT 0,
    "total_hours" numeric(5,2),
    "overtime_hours" numeric(5,2) DEFAULT 0,
    "shift_id" "uuid",
    "status" character varying(20) DEFAULT 'present'::character varying,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."audit_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "operation" "text" NOT NULL,
    "table_name" "text",
    "record_id" "text",
    "status" "text" NOT NULL,
    "error_details" "text",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "site_id" "text",
    "action" "text",
    "entity_type" "text",
    "entity_id" "text",
    "old_values" "jsonb",
    "new_values" "jsonb",
    "department" "text",
    "changed_fields" "text"[],
    "ip_address" "inet",
    "user_agent" "text"
);


CREATE TABLE IF NOT EXISTS "public"."consumption_data" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "meter_id" "uuid",
    "reading" numeric(10,2) NOT NULL,
    "reading_date" timestamp with time zone NOT NULL,
    "consumption" numeric(10,2),
    "source" character varying(20) DEFAULT 'manual'::character varying,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "consumption_data_source_check" CHECK ((("source")::"text" = ANY ((ARRAY['manual'::character varying, 'automatic'::character varying, 'remote'::character varying])::"text"[])))
);


CREATE TABLE IF NOT EXISTS "public"."crm_activities" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "contact_id" "uuid",
    "opportunity_id" "uuid",
    "type" "text" NOT NULL,
    "subject" "text" NOT NULL,
    "description" "text",
    "due_date" timestamp with time zone,
    "duration_minutes" integer,
    "completed" boolean DEFAULT false,
    "completed_at" timestamp with time zone,
    "outcome" "text",
    "priority" "text" DEFAULT 'normal'::"text",
    "assigned_to" "uuid",
    "reminder_at" timestamp with time zone,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "crm_activities_priority_check" CHECK (("priority" = ANY (ARRAY['low'::"text", 'normal'::"text", 'high'::"text", 'urgent'::"text"]))),
    CONSTRAINT "crm_activities_type_check" CHECK (("type" = ANY (ARRAY['call'::"text", 'email'::"text", 'meeting'::"text", 'note'::"text", 'task'::"text", 'follow_up'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."crm_contacts" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "type" "text" NOT NULL,
    "company_name" "text",
    "contact_name" "text" NOT NULL,
    "title" "text",
    "email" "text",
    "phone" "text",
    "mobile" "text",
    "website" "text",
    "address" "jsonb",
    "industry" "text",
    "company_size" "text",
    "annual_revenue" numeric,
    "source" "text",
    "assigned_to" "uuid",
    "pipeline_id" "uuid",
    "stage" "text" DEFAULT 'new'::"text" NOT NULL,
    "score" integer DEFAULT 0,
    "tags" "text"[] DEFAULT '{}'::"text"[],
    "next_follow_up" timestamp with time zone,
    "notes" "text",
    "meter_customer_id" "uuid",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "crm_contacts_score_check" CHECK ((("score" >= 0) AND ("score" <= 100))),
    CONSTRAINT "crm_contacts_type_check" CHECK (("type" = ANY (ARRAY['lead'::"text", 'customer'::"text", 'vendor'::"text", 'partner'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."crm_opportunities" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "contact_id" "uuid",
    "name" "text" NOT NULL,
    "description" "text",
    "value" numeric DEFAULT 0 NOT NULL,
    "currency" "text" DEFAULT 'NGN'::"text",
    "probability" integer DEFAULT 0,
    "pipeline_id" "uuid",
    "stage" "text" DEFAULT 'qualification'::"text" NOT NULL,
    "expected_close" "date",
    "assigned_to" "uuid",
    "status" "text" DEFAULT 'open'::"text" NOT NULL,
    "tags" "text"[] DEFAULT '{}'::"text"[],
    "notes" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "crm_opportunities_probability_check" CHECK ((("probability" >= 0) AND ("probability" <= 100))),
    CONSTRAINT "crm_opportunities_status_check" CHECK (("status" = ANY (ARRAY['open'::"text", 'won'::"text", 'lost'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."crm_pipelines" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "stages" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "is_default" boolean DEFAULT false,
    "is_active" boolean DEFAULT true,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."crm_tags" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "color" "text" DEFAULT '#3b82f6'::"text" NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."customers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "customer_id" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "phone" character varying(20),
    "email" character varying(255),
    "address" "text",
    "remark" "text",
    "crm_contact_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "external_id" character varying(50),
    "kyc_level" character varying(20),
    "account_balance" numeric(12,2) DEFAULT 0,
    "certifi_no" "text",
    "site_id" "text",
    "certifi_name" character varying(100)
);


CREATE TABLE IF NOT EXISTS "public"."department_payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "department_id" "uuid" NOT NULL,
    "payment_type" "text" NOT NULL,
    "category" "text" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "amount" numeric(15,2),
    "currency" "text" DEFAULT 'NGN'::"text",
    "recurrence_period" "text",
    "next_payment_due" timestamp with time zone,
    "last_payment_date" timestamp with time zone,
    "payment_date" timestamp with time zone,
    "status" "text" DEFAULT 'due'::"text",
    "payment_reference" "text",
    "notes" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "issuer_name" "text",
    "issuer_phone_number" "text",
    "issuer_address" "text",
    "amount_paid" numeric DEFAULT 0,
    "invoice_number" "text",
    "site_id" "uuid",
    "site_name" "text",
    "site_state" "text",
    "site_serial_number" "text",
    CONSTRAINT "department_payments_payment_type_check" CHECK (("payment_type" = ANY (ARRAY['one-time'::"text", 'recurring'::"text"]))),
    CONSTRAINT "department_payments_recurrence_period_check" CHECK (("recurrence_period" = ANY (ARRAY['daily'::"text", 'weekly'::"text", 'monthly'::"text", 'quarterly'::"text", 'yearly'::"text"]))),
    CONSTRAINT "department_payments_status_check" CHECK (("status" = ANY (ARRAY['due'::"text", 'paid'::"text", 'overdue'::"text", 'cancelled'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."departments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "department_head_id" "uuid",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."employee_salaries" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "basic_salary" numeric(10,2) NOT NULL,
    "effective_from" "date" NOT NULL,
    "effective_to" "date",
    "is_active" boolean DEFAULT true,
    "bank_account_number" character varying(50),
    "bank_name" character varying(100),
    "bank_sort_code" character varying(20),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."employee_suspensions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "employee_id" "uuid" NOT NULL,
    "suspended_by" "uuid",
    "reason" "text" NOT NULL,
    "start_date" "date" DEFAULT CURRENT_DATE NOT NULL,
    "end_date" "date",
    "is_active" boolean DEFAULT true,
    "lifted_by" "uuid",
    "lifted_at" timestamp with time zone,
    "lift_reason" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."event_notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "event_id" "text",
    "meter_id" "uuid",
    "odyssey_meter_id" "text",
    "event_type" "text" NOT NULL,
    "severity" "text" DEFAULT 'low'::"text",
    "description" "text" NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    "acknowledged" boolean DEFAULT false,
    "acknowledged_by" "uuid",
    "acknowledged_at" timestamp with time zone,
    "metadata" "jsonb",
    "source" "text" DEFAULT 'local'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "site_id" character varying(50),
    CONSTRAINT "event_notifications_severity_check" CHECK (("severity" = ANY (ARRAY['low'::"text", 'medium'::"text", 'high'::"text", 'critical'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."feedback" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "feedback_type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "status" "text" DEFAULT 'open'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_anonymous" boolean DEFAULT false,
    CONSTRAINT "feedback_feedback_type_check" CHECK (("feedback_type" = ANY (ARRAY['concern'::"text", 'complaint'::"text", 'suggestion'::"text", 'required_item'::"text"]))),
    CONSTRAINT "feedback_status_check" CHECK (("status" = ANY (ARRAY['open'::"text", 'in_progress'::"text", 'resolved'::"text", 'closed'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."firmware_tasks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "firmware_id" "uuid",
    "meter_id" "uuid",
    "task_id" character varying(100),
    "status" character varying(50) DEFAULT 'queued'::character varying,
    "progress" integer DEFAULT 0,
    "started_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "error_log" "text"
);


CREATE TABLE IF NOT EXISTS "public"."firmware_updates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "version" character varying(50) NOT NULL,
    "file_url" "text" NOT NULL,
    "release_notes" "text",
    "target_models" "text"[],
    "is_critical" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."gateways" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "gateway_id" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "status" character varying(20) DEFAULT 'offline'::character varying,
    "location" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "gateways_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['online'::character varying, 'offline'::character varying])::"text"[])))
);


CREATE TABLE IF NOT EXISTS "public"."goals_objectives" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "review_cycle_id" "uuid",
    "title" character varying(200) NOT NULL,
    "description" "text",
    "target_value" numeric(10,2),
    "achieved_value" numeric(10,2) DEFAULT 0,
    "status" character varying(20) DEFAULT 'pending'::character varying,
    "priority" character varying(20) DEFAULT 'medium'::character varying,
    "due_date" "date",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."gprs_status" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "meter_id" "uuid",
    "odyssey_meter_id" "text",
    "is_online" boolean DEFAULT false,
    "last_seen" timestamp with time zone,
    "signal_strength" integer,
    "connection_type" "text",
    "apn" "text",
    "ip_address" "inet",
    "uptime_percentage" numeric(5,2),
    "last_disconnect_reason" "text",
    "heartbeat_interval" integer,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "gprs_status_signal_strength_check" CHECK ((("signal_strength" >= 0) AND ("signal_strength" <= 31)))
);


CREATE TABLE IF NOT EXISTS "public"."gprs_tasks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "task_id" character varying(100) NOT NULL,
    "meter_id" "uuid",
    "task_type" character varying(50) NOT NULL,
    "command_payload" "jsonb",
    "status" character varying(50) DEFAULT 'pending'::character varying,
    "result_payload" "jsonb",
    "executed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."interviews" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "application_id" "uuid" NOT NULL,
    "interview_type" character varying(50),
    "scheduled_date" timestamp with time zone,
    "interviewer_id" "uuid",
    "location" "text",
    "status" character varying(20) DEFAULT 'scheduled'::character varying,
    "feedback" "text",
    "rating" numeric(3,1),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."job_postings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" character varying(200) NOT NULL,
    "department" character varying(100),
    "job_type" character varying(50),
    "location" character varying(100),
    "description" "text" NOT NULL,
    "requirements" "text",
    "salary_range_min" numeric(10,2),
    "salary_range_max" numeric(10,2),
    "status" character varying(20) DEFAULT 'draft'::character varying,
    "posted_by" "uuid",
    "posted_at" timestamp with time zone,
    "closing_date" "date",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."leave_approvals" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "leave_request_id" "uuid" NOT NULL,
    "approver_id" "uuid" NOT NULL,
    "approval_level" integer NOT NULL,
    "status" character varying(20) DEFAULT 'pending'::character varying,
    "comments" "text",
    "approved_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."leave_balances" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "leave_type_id" "uuid" NOT NULL,
    "year" integer NOT NULL,
    "allocated_days" integer DEFAULT 0 NOT NULL,
    "used_days" integer DEFAULT 0 NOT NULL,
    "carry_forward_days" integer DEFAULT 0,
    "balance_days" integer GENERATED ALWAYS AS ((("allocated_days" + "carry_forward_days") - "used_days")) STORED,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."leave_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "leave_type_id" "uuid" NOT NULL,
    "start_date" "date" NOT NULL,
    "end_date" "date" NOT NULL,
    "days_count" integer NOT NULL,
    "reason" "text" NOT NULL,
    "status" character varying(20) DEFAULT 'pending'::character varying,
    "approved_by" "uuid",
    "approved_at" timestamp with time zone,
    "rejected_reason" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."leave_types" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(100) NOT NULL,
    "code" character varying(20) NOT NULL,
    "max_days" integer NOT NULL,
    "is_paid" boolean DEFAULT true,
    "carry_forward" boolean DEFAULT false,
    "requires_approval" boolean DEFAULT true,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."meter_readings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "meter_id" "uuid",
    "odyssey_meter_id" "text",
    "reading_value" numeric(12,2) NOT NULL,
    "reading_type" "text" DEFAULT 'hourly'::"text",
    "timestamp" timestamp with time zone NOT NULL,
    "voltage" numeric(8,2),
    "current" numeric(8,2),
    "active_power" numeric(10,2),
    "reactive_power" numeric(10,2),
    "power_factor" numeric(4,2),
    "frequency" numeric(5,2),
    "consumption" numeric(10,2),
    "demand" numeric(10,2),
    "voltage_phase_a" numeric(8,2),
    "voltage_phase_b" numeric(8,2),
    "voltage_phase_c" numeric(8,2),
    "current_phase_a" numeric(8,2),
    "current_phase_b" numeric(8,2),
    "current_phase_c" numeric(8,2),
    "source" "text" DEFAULT 'local'::"text",
    "synced_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "site_id" character varying(50),
    "energy_balance_kwh" numeric,
    "energy_consumption_kwh" numeric,
    "energy_reading_kwh" numeric,
    "time_interval_minutes" integer DEFAULT 60,
    "customer_account_id" "text",
    CONSTRAINT "meter_readings_reading_type_check" CHECK (("reading_type" = ANY (ARRAY['hourly'::"text", 'daily'::"text", 'monthly'::"text", 'instantaneous'::"text"]))),
    CONSTRAINT "meter_readings_source_check" CHECK (("source" = ANY (ARRAY['local'::"text", 'odyssey'::"text", 'migrated'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."meters" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "meter_id" character varying(20) NOT NULL,
    "customer_id" "uuid",
    "tariff_id" "uuid",
    "gateway_id" "uuid",
    "meter_type" character varying(50) DEFAULT 'single_phase'::character varying NOT NULL,
    "status" character varying(20) DEFAULT 'online'::character varying,
    "install_date" "date",
    "last_reading" numeric(10,2),
    "last_reading_date" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "serial_number" "text",
    "meter_model" "text",
    "firmware_version" "text",
    "location" "jsonb",
    "metadata" "jsonb",
    "odyssey_meter_id" "text",
    "last_sync_at" timestamp with time zone,
    "sync_status" "text" DEFAULT 'synced'::"text",
    "phase_type" character varying(20),
    "model_name" character varying(100),
    "last_communication_at" timestamp with time zone,
    "site_id" character varying(50),
    CONSTRAINT "meters_status_check" CHECK ((("status")::"text" = ANY (ARRAY['online'::"text", 'offline'::"text", 'active'::"text", 'inactive'::"text"]))),
    CONSTRAINT "meters_sync_status_check" CHECK (("sync_status" = ANY (ARRAY['synced'::"text", 'pending'::"text", 'error'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."notification_preferences" (
    "user_id" "uuid" NOT NULL,
    "in_app_enabled" boolean DEFAULT true NOT NULL,
    "email_enabled" boolean DEFAULT true NOT NULL,
    "tasks_enabled" boolean DEFAULT true NOT NULL,
    "assets_enabled" boolean DEFAULT true NOT NULL,
    "feedback_enabled" boolean DEFAULT true NOT NULL,
    "approvals_enabled" boolean DEFAULT true NOT NULL,
    "system_enabled" boolean DEFAULT true NOT NULL,
    "mentions_enabled" boolean DEFAULT true NOT NULL,
    "email_frequency" "text" DEFAULT 'immediate'::"text" NOT NULL,
    "quiet_hours_start" time without time zone,
    "quiet_hours_end" time without time zone,
    "auto_mark_read_on_click" boolean DEFAULT true NOT NULL,
    "show_previews" boolean DEFAULT true NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "notification_preferences_email_frequency_check" CHECK (("email_frequency" = ANY (ARRAY['immediate'::"text", 'hourly'::"text", 'daily'::"text", 'weekly'::"text", 'never'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "message" "text" NOT NULL,
    "data" "jsonb" DEFAULT '{}'::"jsonb",
    "read" boolean DEFAULT false,
    "action_url" "text",
    "priority" "text" DEFAULT 'normal'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "read_at" timestamp with time zone,
    CONSTRAINT "notifications_priority_check" CHECK (("priority" = ANY (ARRAY['low'::"text", 'normal'::"text", 'high'::"text", 'urgent'::"text"]))),
    CONSTRAINT "notifications_type_check" CHECK (("type" = ANY (ARRAY['token_generated'::"text", 'token_cancelled'::"text", 'task_completed'::"text", 'task_failed'::"text", 'customer_added'::"text", 'customer_updated'::"text", 'meter_status_change'::"text", 'meter_added'::"text", 'activity_reminder'::"text", 'crm_contact_added'::"text", 'opportunity_won'::"text", 'opportunity_lost'::"text", 'system_alert'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."offers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "application_id" "uuid" NOT NULL,
    "offer_salary" numeric(10,2) NOT NULL,
    "offer_date" "date" NOT NULL,
    "start_date" "date" NOT NULL,
    "status" character varying(20) DEFAULT 'pending'::character varying,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."office_locations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "type" "text" NOT NULL,
    "department" "text",
    "description" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "site" "text",
    CONSTRAINT "office_locations_type_check" CHECK (("type" = ANY (ARRAY['office'::"text", 'department_office'::"text", 'conference_room'::"text", 'common_area'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."overtime_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "date" "date" NOT NULL,
    "hours" numeric(4,2) NOT NULL,
    "reason" "text" NOT NULL,
    "status" character varying(20) DEFAULT 'pending'::character varying,
    "approved_by" "uuid",
    "approved_at" timestamp with time zone,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."payment_categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."payment_documents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "payment_id" "uuid" NOT NULL,
    "document_type" "text" NOT NULL,
    "file_name" "text" NOT NULL,
    "file_path" "text" NOT NULL,
    "file_size" bigint,
    "mime_type" "text",
    "description" "text",
    "uploaded_by" "uuid",
    "uploaded_at" timestamp with time zone DEFAULT "now"(),
    "applicable_date" "date",
    "is_archived" boolean DEFAULT false,
    "replaced_by" "uuid",
    "archived_at" timestamp with time zone,
    CONSTRAINT "payment_documents_document_type_check" CHECK (("document_type" = ANY (ARRAY['invoice'::"text", 'receipt'::"text", 'requisition'::"text", 'approval'::"text", 'other'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."payroll_entries" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "payroll_period_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "basic_salary" numeric(10,2) NOT NULL,
    "gross_salary" numeric(10,2) NOT NULL,
    "total_deductions" numeric(10,2) DEFAULT 0,
    "net_salary" numeric(10,2) NOT NULL,
    "tax_amount" numeric(10,2) DEFAULT 0,
    "bonus" numeric(10,2) DEFAULT 0,
    "overtime_pay" numeric(10,2) DEFAULT 0,
    "leave_deduction" numeric(10,2) DEFAULT 0,
    "other_deductions" numeric(10,2) DEFAULT 0,
    "status" character varying(20) DEFAULT 'pending'::character varying,
    "payslip_generated" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."payroll_periods" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(100) NOT NULL,
    "start_date" "date" NOT NULL,
    "end_date" "date" NOT NULL,
    "pay_date" "date" NOT NULL,
    "status" character varying(20) DEFAULT 'draft'::character varying,
    "total_amount" numeric(12,2) DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."payslips" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "payroll_entry_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "payroll_period_id" "uuid" NOT NULL,
    "payslip_number" character varying(50) NOT NULL,
    "pdf_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."pending_users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "email" "text" NOT NULL,
    "first_name" "text",
    "last_name" "text",
    "other_names" "text",
    "department" "text",
    "company_role" "text",
    "phone_number" "text",
    "residential_address" "text",
    "current_work_location" "text",
    "device_allocated" "text",
    "device_type" "text",
    "device_model" "text",
    "status" "text" DEFAULT 'pending'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "pending_users_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'approved'::"text", 'rejected'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."performance_ratings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "performance_review_id" "uuid" NOT NULL,
    "criterion" character varying(200) NOT NULL,
    "rating" numeric(3,1) NOT NULL,
    "comments" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."performance_reviews" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "review_cycle_id" "uuid" NOT NULL,
    "reviewer_id" "uuid" NOT NULL,
    "review_date" "date" NOT NULL,
    "overall_rating" numeric(3,1),
    "status" character varying(20) DEFAULT 'draft'::character varying,
    "self_review_completed" boolean DEFAULT false,
    "manager_review_completed" boolean DEFAULT false,
    "employee_comments" "text",
    "manager_comments" "text",
    "goals_achieved" integer DEFAULT 0,
    "goals_total" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "first_name" "text",
    "last_name" "text",
    "other_names" "text",
    "department" "text",
    "company_role" "text",
    "company_email" "text",
    "phone_number" "text",
    "additional_phone" "text",
    "residential_address" "text",
    "current_work_location" "text",
    "device_allocated" "text",
    "device_type" "text",
    "device_model" "text",
    "is_admin" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "devices" "jsonb",
    "bank_name" "text",
    "bank_account_number" "text",
    "bank_account_name" "text",
    "date_of_birth" "date",
    "employment_date" "date",
    "role" "public"."user_role" DEFAULT 'employee'::text,
    "is_department_lead" boolean DEFAULT false,
    "lead_departments" "text"[] DEFAULT '{}'::"text"[],
    "job_description" "text",
    "job_description_updated_at" timestamp with time zone,
    "office_location" "text",
    "full_name" "text" GENERATED ALWAYS AS (TRIM(BOTH FROM ((COALESCE("first_name", ''::"text") || ' '::"text") || COALESCE("last_name", ''::"text")))) STORED,
    "department_id" "uuid",
    "employment_status" "public"."employment_status" DEFAULT 'active'::"public"."employment_status",
    "status_changed_at" timestamp with time zone,
    "status_changed_by" "uuid",
    "termination_date" "date",
    "termination_reason" "text",
    "employee_number" "text",
    "email_notifications" boolean DEFAULT false,
    CONSTRAINT "check_lead_has_departments" CHECK ((("role" <> 'lead'::text) OR (("lead_departments" IS NOT NULL) AND ("array_length"("lead_departments", 1) > 0)))),
    CONSTRAINT "profiles_employee_number_format" CHECK ((("employee_number" IS NULL) OR ("employee_number" ~ '^ACOB/[0-9]{4}/[0-9]{3}$'::"text"))),
    CONSTRAINT "profiles_office_location_check" CHECK ((("office_location" IS NULL) OR ("office_location" = ANY (ARRAY['Accounts'::"text", 'Admin & HR'::"text", 'Assistant Executive Director'::"text", 'Business, Growth and Innovation'::"text", 'General Conference Room'::"text", 'IT and Communications'::"text", 'Kitchen'::"text", 'Legal, Regulatory and Compliance'::"text", 'MD Conference Room'::"text", 'MD Office'::"text", 'Operations'::"text", 'Reception'::"text", 'Site'::"text", 'Technical'::"text", 'Technical Extension'::"text"]))))
);


CREATE TABLE IF NOT EXISTS "public"."project_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "project_id" "uuid" NOT NULL,
    "item_name" "text" NOT NULL,
    "description" "text",
    "quantity" integer DEFAULT 1,
    "unit" "text",
    "status" "text" DEFAULT 'pending'::"text",
    "notes" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "project_items_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'ordered'::"text", 'received'::"text", 'installed'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."project_members" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "project_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'member'::"text",
    "assigned_by" "uuid",
    "assigned_at" timestamp with time zone DEFAULT "now"(),
    "removed_at" timestamp with time zone,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "project_members_role_check" CHECK (("role" = ANY (ARRAY['member'::"text", 'lead'::"text", 'manager'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."project_updates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "project_id" "uuid" NOT NULL,
    "user_id" "uuid",
    "update_type" "text",
    "content" "text",
    "old_value" "text",
    "new_value" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "project_updates_update_type_check" CHECK (("update_type" = ANY (ARRAY['comment'::"text", 'status_change'::"text", 'milestone'::"text", 'member_added'::"text", 'member_removed'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."projects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "project_name" "text" NOT NULL,
    "location" "text" NOT NULL,
    "deployment_start_date" "date" NOT NULL,
    "deployment_end_date" "date" NOT NULL,
    "capacity_w" numeric,
    "technology_type" "text",
    "project_manager_id" "uuid",
    "description" "text",
    "status" "text" DEFAULT 'planning'::"text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "completed_at" timestamp with time zone,
    CONSTRAINT "projects_status_check" CHECK (("status" = ANY (ARRAY['planning'::"text", 'active'::"text", 'on_hold'::"text", 'completed'::"text", 'cancelled'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."remote_tasks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "meter_id" "uuid",
    "task_type" character varying(20) NOT NULL,
    "operation" character varying(20),
    "parameters" "jsonb",
    "status" character varying(20) DEFAULT 'pending'::character varying,
    "result" "jsonb",
    "error_message" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "completed_at" timestamp with time zone,
    "task_id" "text",
    "odyssey_task_id" "text",
    "estimated_completion" timestamp with time zone,
    "retry_count" integer DEFAULT 0,
    "last_retry_at" timestamp with time zone,
    CONSTRAINT "remote_tasks_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'completed'::character varying, 'failed'::character varying])::"text"[]))),
    CONSTRAINT "remote_tasks_task_type_check" CHECK ((("task_type")::"text" = ANY ((ARRAY['token'::character varying, 'control'::character varying, 'reading'::character varying])::"text"[])))
);


CREATE TABLE IF NOT EXISTS "public"."review_cycles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(100) NOT NULL,
    "start_date" "date" NOT NULL,
    "end_date" "date" NOT NULL,
    "review_type" character varying(50) NOT NULL,
    "status" character varying(20) DEFAULT 'draft'::character varying,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "permissions" "text"[] DEFAULT '{}'::"text"[],
    "is_system" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."salary_components" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(100) NOT NULL,
    "code" character varying(20) NOT NULL,
    "type" character varying(20) NOT NULL,
    "is_taxable" boolean DEFAULT true,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."salary_structures" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "employee_salary_id" "uuid" NOT NULL,
    "salary_component_id" "uuid" NOT NULL,
    "amount" numeric(10,2) NOT NULL,
    "percentage" numeric(5,2),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."shifts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(100) NOT NULL,
    "start_time" time without time zone NOT NULL,
    "end_time" time without time zone NOT NULL,
    "department" character varying(100),
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."starlink_documents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "payment_id" "uuid" NOT NULL,
    "document_type" "text" NOT NULL,
    "file_name" "text" NOT NULL,
    "file_path" "text" NOT NULL,
    "file_size" bigint,
    "mime_type" "text",
    "description" "text",
    "uploaded_by" "uuid",
    "uploaded_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "starlink_documents_document_type_check" CHECK (("document_type" = ANY (ARRAY['invoice'::"text", 'receipt'::"text", 'requisition'::"text", 'other'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."starlink_payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid" NOT NULL,
    "invoice_number" "text" NOT NULL,
    "billing_period_start" "date" NOT NULL,
    "billing_period_end" "date" NOT NULL,
    "next_payment_due" "date" NOT NULL,
    "amount" numeric(10,2),
    "currency" "text" DEFAULT 'NGN'::"text",
    "payment_status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "payment_date" "date",
    "payment_reference" "text",
    "reminder_sent" boolean DEFAULT false NOT NULL,
    "reminder_sent_at" timestamp with time zone,
    "requisition_raised" boolean DEFAULT false NOT NULL,
    "requisition_raised_at" timestamp with time zone,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    CONSTRAINT "starlink_payments_dates_check" CHECK (("billing_period_end" > "billing_period_start")),
    CONSTRAINT "starlink_payments_payment_status_check" CHECK (("payment_status" = ANY (ARRAY['pending'::"text", 'paid'::"text", 'overdue'::"text", 'cancelled'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."starlink_sites" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "state" "text" NOT NULL,
    "site_name" "text" NOT NULL,
    "email" "text" NOT NULL,
    "phone_number" "text" NOT NULL,
    "serial_number" "text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "migrated_to_department_payments" boolean DEFAULT false,
    CONSTRAINT "starlink_sites_email_check" CHECK (("email" ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::"text"))
);


CREATE TABLE IF NOT EXISTS "public"."sync_state" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sync_type" "text" NOT NULL,
    "last_sync_at" timestamp with time zone NOT NULL,
    "last_sync_from" timestamp with time zone,
    "last_sync_to" timestamp with time zone,
    "records_synced" integer DEFAULT 0,
    "status" "text" DEFAULT 'success'::"text",
    "error_message" "text",
    "metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "sync_state_status_check" CHECK (("status" = ANY (ARRAY['success'::"text", 'partial'::"text", 'failed'::"text"]))),
    CONSTRAINT "sync_state_sync_type_check" CHECK (("sync_type" = ANY (ARRAY['tokens'::"text", 'readings'::"text", 'tasks'::"text", 'events'::"text", 'gprs_status'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."system_settings" (
    "key" "text" NOT NULL,
    "value" "jsonb" NOT NULL,
    "description" "text",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "updated_by" "uuid"
);


CREATE TABLE IF NOT EXISTS "public"."tariffs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tariff_id" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "category" character varying(20),
    "price_per_kwh" numeric(10,2) NOT NULL,
    "vat_rate" numeric(5,2) DEFAULT 7.5,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "tariffs_category_check" CHECK ((("category")::"text" = ANY ((ARRAY['RESIDENTIAL'::character varying, 'COMMERCIAL'::character varying, 'PRODUCTIVE'::character varying, 'PUBLIC'::character varying])::"text"[])))
);


CREATE TABLE IF NOT EXISTS "public"."task_assignments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "task_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "assigned_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."task_updates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "task_id" "uuid",
    "user_id" "uuid",
    "update_type" "text",
    "content" "text",
    "old_value" "text",
    "new_value" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."task_user_completion" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "task_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "completed_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."tasks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "priority" "text" DEFAULT 'medium'::"text",
    "status" "text" DEFAULT 'pending'::"text",
    "assigned_to" "uuid",
    "assigned_by" "uuid",
    "department" "text",
    "due_date" "date",
    "started_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "progress" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "assignment_type" "text" DEFAULT 'individual'::"text",
    "project_id" "uuid",
    "task_start_date" "date",
    "task_end_date" "date",
    "category" "text" DEFAULT 'general'::"text",
    "week_number" integer,
    "year" integer,
    CONSTRAINT "tasks_assignment_type_check" CHECK (("assignment_type" = ANY (ARRAY['individual'::"text", 'multiple'::"text", 'department'::"text"])))
);


CREATE TABLE IF NOT EXISTS "public"."timesheets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "week_start_date" "date" NOT NULL,
    "week_end_date" "date" NOT NULL,
    "total_hours" numeric(6,2) DEFAULT 0,
    "overtime_hours" numeric(6,2) DEFAULT 0,
    "status" character varying(20) DEFAULT 'draft'::character varying,
    "approved_by" "uuid",
    "approved_at" timestamp with time zone,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."token_records" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "customer_id" "uuid",
    "meter_id" "uuid",
    "token_type" character varying(20) NOT NULL,
    "token" character varying(50) NOT NULL,
    "amount" numeric(10,2),
    "units" numeric(10,2),
    "power_limit" numeric(10,2),
    "status" character varying(20) DEFAULT 'active'::character varying,
    "generated_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "receipt_id" "text",
    "tariff_rate" numeric(10,2),
    "vat_amount" numeric(10,2),
    "total_amount" numeric(10,2),
    "used_at" timestamp with time zone,
    "source" "text" DEFAULT 'local'::"text",
    "odyssey_token_id" "text",
    "synced_at" timestamp with time zone,
    "generated_at" timestamp with time zone DEFAULT "now"(),
    "odyssey_data" "jsonb",
    "currency" "text" DEFAULT 'NAIRA'::"text",
    "transaction_type" "text",
    "odyssey_meter_id" "text",
    "odyssey_customer_id" "text",
    "serial_number" "text",
    "site_id" character varying(50),
    CONSTRAINT "token_records_source_check" CHECK (("source" = ANY (ARRAY['local'::"text", 'odyssey'::"text", 'migrated'::"text"]))),
    CONSTRAINT "token_records_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['active'::character varying, 'cancelled'::character varying, 'expired'::character varying])::"text"[]))),
    CONSTRAINT "token_records_token_type_check" CHECK ((("token_type")::"text" = ANY ((ARRAY['credit'::character varying, 'clear_tamper'::character varying, 'clear_credit'::character varying, 'max_power'::character varying])::"text"[])))
);


CREATE TABLE IF NOT EXISTS "public"."token_sales" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "customer_id" "uuid",
    "meter_id" "uuid",
    "token" character varying(50) NOT NULL,
    "amount" numeric(10,2) NOT NULL,
    "units" numeric(10,2) NOT NULL,
    "vat" numeric(10,2),
    "total_amount" numeric(10,2),
    "tariff_rate" numeric(10,2),
    "status" character varying(20) DEFAULT 'active'::character varying,
    "generated_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "token_sales_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['active'::character varying, 'cancelled'::character varying, 'expired'::character varying])::"text"[])))
);


CREATE TABLE IF NOT EXISTS "public"."user_documentation" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "title" "text" NOT NULL,
    "content" "text" NOT NULL,
    "category" "text",
    "tags" "text"[],
    "is_draft" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "role" character varying(20) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "user_roles_role_check" CHECK ((("role")::"text" = ANY ((ARRAY['super_admin'::character varying, 'admin'::character varying, 'lead'::character varying, 'employee'::character varying, 'visitor'::character varying])::"text"[])))
);


CREATE TABLE IF NOT EXISTS "public"."weekly_reports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "department" "text" NOT NULL,
    "week_number" integer NOT NULL,
    "year" integer NOT NULL,
    "work_done" "text",
    "tasks_new_week" "text",
    "challenges" "text",
    "status" "text" DEFAULT 'draft'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "weekly_reports_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'submitted'::"text"])))
);

