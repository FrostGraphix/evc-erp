# EVC ERP

EVC ERP is the internal enterprise resource planning and staff platform for EVC, served at **https://erp.evcng.com**. It is a private, sign-in-only application for EVC staff (`@evcng.com` accounts). It is not a public website, and nothing in this repo is meant for anonymous visitors. The public company site is [evcng.com](https://evcng.com).

## Company & Contact Details

- **Company**: EVC
- **Website**: [evcng.com](https://evcng.com)
- **Portal**: [https://erp.evcng.com](https://erp.evcng.com)
- **Primary Email**: contact@evcng.com
- **Phone**: +234 708 293 8870
- **Instagram**: [@evc_ng](https://instagram.com/evc_ng)

## What it covers

| Area | Examples |
| --- | --- |
| HR | Attendance and clock-in, leave, onboarding, payroll, PMS and review cycles, CBT |
| Work | Tasks, projects, goals, weekly reports, meetings and KSS rotation |
| Operations | Help desk, assets and inventory, purchasing, payments, Starlink billing |
| Communications | Notifications (in-app, email, web push), correspondence, events calendar, MD's Desk, birthdays |
| Governance | Audit logs, policies and SOPs, risk register, corporate scorecard, security |
| Tools | Email signature creator and other staff utilities |

Staff-facing pages live under `app/(app)`; admin pages live under `app/admin`.

## Tech Stack

- **Framework**: Next.js 16 (App Router) + React 19 + TypeScript
- **Styling & UI**: Tailwind CSS 4 + shadcn/ui primitives + Lucide icons
- **Database & Backend**: Supabase (PostgreSQL with Row Level Security, Auth, Storage, Edge Functions in Deno, `pg_cron`)
- **Email & Communications**: Resend for transactional emails
- **Caching & Rate Limiting**: Upstash Redis
- **Hosting & Infrastructure**: Vercel (Edge & Serverless)
- **Document & PDF Processing**: In-browser PDF engine (`pdf-lib`, `jspdf`, `pptxgenjs`, `docx`)

## Getting started

Requires Node 24 and access to the Supabase project.

```bash
npm install
cp .env.example .env.local   # then fill in the values — contact IT for secrets
npm run dev                  # http://localhost:3000
```

`.env.example` documents every variable. Only the Supabase, Resend and site-URL
groups are required to boot; the rest switch on optional integrations
(OneDrive, document service, help-desk SLAs, cron).

Never commit `.env.local` or any service-role key.

## Checking your work

Use the fast checks. **Do not run `npm run build` locally** — it takes several
minutes and fights the dev server for `.next/`. Vercel is the only place the
production build runs.

```bash
npm run type-check          # tsc --noEmit
npm run lint:strict         # ESLint, zero warnings allowed
npm test                    # unit test suites (tsx --test)
npm run test:e2e            # Playwright
```

Individual suites are available as `npm run test:<area>` (e.g. `test:attendance`,
`test:admin-scope`, `test:starlink`).

## Project conventions

[AGENTS.md](AGENTS.md) is the source of truth for engineering standards and UI
patterns — table pages (`DataTablePage` + `DataTable`), stat cards, typing,
commit grouping and migration rules. Read it before making changes. It applies
to human contributors and AI agents alike.

## Repository layout

```
app/            Routes — (app) staff pages, admin, api, auth
components/     Shared UI (components/ui = shadcn-based primitives)
lib/            Domain logic, grouped by area (hr, tasks, starlink, …)
supabase/       Migrations, edge functions, config
scripts/        Maintenance, audits, test campaigns
docs/           Runbooks, audits, implementation notes, user guide
tests/          Playwright end-to-end tests
```

## Access and support

EVC ERP accounts are provisioned by IT; staff activate theirs at
`/auth/setup-account`. For access, bugs or questions, contact IT Support at **contact@evcng.com**.

This is proprietary software of EVC. All rights reserved.
