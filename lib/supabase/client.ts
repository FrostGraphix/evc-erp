import { createBrowserClient } from "@supabase/ssr"
import { SESSION_MAX_AGE_SECONDS } from "@/lib/supabase/cookie-policy"

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookieOptions: {
        maxAge: SESSION_MAX_AGE_SECONDS,
        sameSite: "lax",
        secure: process.env.NODE_ENV === "production",
        path: "/",
      },
    }
  )
}
