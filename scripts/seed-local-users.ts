import { createClient } from "@supabase/supabase-js"
import { config } from "dotenv"
import path from "path"

// Load environment variables from .env.local or .env
config({ path: path.resolve(process.cwd(), ".env.local") })
config({ path: path.resolve(process.cwd(), ".env") })

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || "http://127.0.0.1:54321"
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzQzNzYwMH0.dummy"

const DEFAULT_PASSWORD = "Password123!"

export const SEED_ACCOUNTS = [
  {
    email: "admin@evcng.com",
    password: DEFAULT_PASSWORD,
    firstName: "Danmusa",
    lastName: "Abdulsamad",
    role: "super_admin" as const,
    isAdmin: true,
    department: "Executive Management",
    designation: "Managing Director",
    employeeNumber: "EVC/2026/001",
    gender: "male",
    isDepartmentLead: true,
    leadDepartments: ["Executive Management"],
    adminRoutes: [
      "accounts",
      "assets",
      "audit-logs",
      "communications",
      "corporate-services",
      "documentation",
      "employees",
      "feedback",
      "hr",
      "inventory",
      "it",
      "job-descriptions",
      "md-desk",
      "notification",
      "payments",
      "payroll",
      "pms",
      "projects",
      "reports",
      "security",
      "settings",
      "tasks",
    ],
  },
  {
    email: "hr@evcng.com",
    password: DEFAULT_PASSWORD,
    firstName: "Amina",
    lastName: "Bello",
    role: "admin" as const,
    isAdmin: true,
    department: "Admin & HR",
    designation: "HR Manager",
    employeeNumber: "EVC/2026/002",
    gender: "female",
    isDepartmentLead: true,
    leadDepartments: ["Admin & HR"],
    adminRoutes: ["hr", "employees", "job-descriptions", "reports", "settings"],
  },
  {
    email: "it@evcng.com",
    password: DEFAULT_PASSWORD,
    firstName: "Tunde",
    lastName: "Okafor",
    role: "developer" as const,
    isAdmin: true,
    department: "IT and Communications",
    designation: "Lead Systems Engineer",
    employeeNumber: "EVC/2026/003",
    gender: "male",
    isDepartmentLead: true,
    leadDepartments: ["IT and Communications"],
    adminRoutes: ["it", "security", "audit-logs", "settings"],
  },
  {
    email: "lead@evcng.com",
    password: DEFAULT_PASSWORD,
    firstName: "Fatima",
    lastName: "Garba",
    role: "employee" as const,
    isAdmin: false,
    department: "Operations",
    designation: "Operations Lead",
    employeeNumber: "EVC/2026/004",
    gender: "female",
    isDepartmentLead: true,
    leadDepartments: ["Operations"],
    adminRoutes: [],
  },
  {
    email: "staff@evcng.com",
    password: DEFAULT_PASSWORD,
    firstName: "Blessing",
    lastName: "Funsho",
    role: "employee" as const,
    isAdmin: false,
    department: "Corporate Services",
    designation: "Project Associate",
    employeeNumber: "EVC/2026/005",
    gender: "female",
    isDepartmentLead: false,
    leadDepartments: [],
    adminRoutes: [],
  },
]

async function seed() {
  console.log(`\n======================================================`)
  console.log(` EVC ERP — Local Auth Seeding Script`)
  console.log(` Target Supabase URL: ${supabaseUrl}`)
  console.log(`======================================================\n`)

  const supabase = createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  })

  // Test database connection and inspect profile columns
  try {
    const { data: sampleProfile, error: pingError } = await supabase.from("profiles").select("*").limit(1)
    if (pingError) {
      console.warn(`[Notice] profiles select error: ${pingError.message}`)
    } else if (sampleProfile && sampleProfile.length > 0) {
      console.log(`[Schema] Detected profiles columns:`, Object.keys(sampleProfile[0]).join(", "))
    }
  } catch (err: unknown) {
    console.warn(`[Notice] Could not verify database ping:`, err)
  }

  for (const account of SEED_ACCOUNTS) {
    console.log(`Creating/Verifying: ${account.email} (${account.role})...`)

    let userId: string | null = null

    // Check if user already exists in auth
    const { data: listData, error: listError } = await supabase.auth.admin.listUsers()
    if (!listError && listData?.users) {
      const existing = listData.users.find((u) => u.email?.toLowerCase() === account.email.toLowerCase())
      if (existing) {
        userId = existing.id
        console.log(`  -> User exists in auth.users (ID: ${userId})`)
        // Update password & confirm
        await supabase.auth.admin.updateUserById(userId, {
          password: account.password,
          email_confirm: true,
          user_metadata: {
            first_name: account.firstName,
            last_name: account.lastName,
            full_name: `${account.firstName} ${account.lastName}`,
          },
        })
      }
    }

    // If not found, create via Admin API
    if (!userId) {
      const { data: createData, error: createError } = await supabase.auth.admin.createUser({
        email: account.email,
        password: account.password,
        email_confirm: true,
        user_metadata: {
          first_name: account.firstName,
          last_name: account.lastName,
          full_name: `${account.firstName} ${account.lastName}`,
        },
      })

      if (createError) {
        console.error(`  [!] Failed to create ${account.email} in auth: ${createError.message}`)
        continue
      }
      userId = createData.user.id
      console.log(`  -> Successfully created auth user (ID: ${userId})`)
    }

    // Sign in as the user to update their own profile with full authenticated permissions
    const client = createClient(supabaseUrl, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || supabaseServiceKey)
    const { data: sessionData, error: sessionError } = await client.auth.signInWithPassword({
      email: account.email,
      password: account.password,
    })

    if (sessionError) {
      console.warn(`  [!] Could not sign in to update profile for ${account.email}: ${sessionError.message}`)
    } else {
      const { error: profileError } = await client
        .from("profiles")
        .update({
          email: account.email,
          first_name: account.firstName,
          last_name: account.lastName,
          full_name: `${account.firstName} ${account.lastName}`,
          position: account.designation,
          role: account.role,
          gender: account.gender,
          is_active: true,
          onboarding_completed: true,
          updated_at: new Date().toISOString(),
        })
        .eq("id", userId)

      if (profileError) {
        console.warn(`  [!] Profile update warning: ${profileError.message}`)
      } else {
        console.log(`  -> Profile updated successfully (role: ${account.role})`)
      }
    }
  }

  console.log(`\n======================================================`)
  console.log(` Seed Summary:`)
  console.log(` Default Password: ${DEFAULT_PASSWORD}`)
  SEED_ACCOUNTS.forEach((acc) => {
    console.log(` - ${acc.email} | Role: ${acc.role} | Dept: ${acc.department} (${acc.designation})`)
  })
  console.log(`======================================================\n`)
}

seed().catch((err) => {
  console.error("Fatal seed error:", err)
  process.exit(1)
})
