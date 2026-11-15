import { escapeHtml, getERPThemeAwareStyles, getERPHeader, getERPFooter } from "./utils"

const ICT_SUPPORT_EMAIL = process.env.ICT_SUPPORT_EMAIL || "contact@evcng.com"
const WEBMAIL_LOGIN_URL = "https://webmail-p21.web-hosting.com/"
const MATRIX_PORTAL_URL = process.env.NEXT_PUBLIC_PORTAL_URL || "https://erp.evcng.com"

export interface PendingUser {
  first_name: string
  last_name: string
  department: string
  designation: string
  company_email: string
  personal_email: string
  employee_number?: string
  phone_number?: string
  office_location?: string
  residential_address?: string
}

interface WelcomeEmailProps {
  pendingUser: PendingUser
  tempPassword: string
  activationUrl: string
  portalUrl?: string
  webmailUrl?: string
  preparedBy?: {
    name?: string | null
    designation?: string | null
    department?: string | null
  }
}

export function renderWelcomeEmail({
  pendingUser,
  tempPassword,
  activationUrl,
  portalUrl = MATRIX_PORTAL_URL,
  webmailUrl = WEBMAIL_LOGIN_URL,
  preparedBy,
}: WelcomeEmailProps) {
  const firstName = escapeHtml(pendingUser.first_name)
  const lastName = escapeHtml(pendingUser.last_name)
  const dept = escapeHtml(pendingUser.department)
  const role = escapeHtml(pendingUser.designation)
  const email = escapeHtml(pendingUser.company_email)
  const staffId = pendingUser.employee_number ? escapeHtml(pendingUser.employee_number) : null
  const officeLoc = pendingUser.office_location ? escapeHtml(pendingUser.office_location) : "N/A"
  const safeTempPassword = escapeHtml(tempPassword)
  const safeWebmailUrl = escapeHtml(webmailUrl)
  const safePortalUrl = escapeHtml(portalUrl)
  const safeActivationUrl = escapeHtml(activationUrl)
  const safeLoginUrl = escapeHtml(`${portalUrl}/auth/login`)
  const preparedByName = escapeHtml((preparedBy?.name || "Admin & IT Team").trim())
  const preparedByDesignation = escapeHtml((preparedBy?.designation || "").trim())
  const preparedByDepartment = escapeHtml((preparedBy?.department || "Admin and HR").trim())

  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to EVC Nig. Ltd. - Account Onboarding</title>
    ${getERPThemeAwareStyles()}
</head>
<body class="email-bg" style="margin: 0; padding: 24px 12px; background: #F8FAFC; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
    <div class="card-box" style="max-width: 620px; margin: 0 auto; background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 18px; overflow: hidden; box-shadow: 0 12px 36px rgba(10, 22, 40, 0.08);">
        ${getERPHeader("Staff Onboarding", "Welcome to the Team!", "Official corporate email and EVC ERP account credentials")}

        <div style="padding: 32px 28px;">
            <p class="body-p" style="font-size: 15px; color: #334155; line-height: 1.6; margin: 0 0 16px 0;">Dear <strong class="body-strong" style="color: #0F172A;">${firstName}</strong>,</p>
            <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 16px 0;">We are excited to welcome you to <strong>EVC Nig. Ltd.</strong>. Your official company profile and corporate email mailbox have been provisioned.</p>
            <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 20px 0;">Please follow the <strong>two steps below</strong> to access your company email and activate your EVC ERP account.</p>
            
            <!-- Employee Profile Summary -->
            <div style="margin-top: 18px; border: 1px solid #E2E8F0; border-radius: 10px; overflow: hidden; background: #F8FAFC;">
                <div style="padding: 10px 16px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; background: #F1F5F9; color: #475569; border-bottom: 1px solid #E2E8F0;">Employee Profile</div>
                <table style="width: 100%; border-collapse: collapse;">
                    <tr>
                        <td style="width: 38%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 10px 16px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Full Name</td>
                        <td style="color: #0F172A; font-weight: 600; padding: 10px 16px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${firstName} ${lastName}</td>
                    </tr>
                    ${staffId ? `<tr><td style="width: 38%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 10px 16px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Staff ID</td><td style="color: #0F172A; font-weight: 600; padding: 10px 16px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${staffId}</td></tr>` : ""}
                    <tr>
                        <td style="width: 38%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 10px 16px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Department</td>
                        <td style="color: #0F172A; font-weight: 600; padding: 10px 16px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${dept}</td>
                    </tr>
                    <tr>
                        <td style="width: 38%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 10px 16px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Designation</td>
                        <td style="color: #0F172A; font-weight: 600; padding: 10px 16px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${role}</td>
                    </tr>
                    <tr>
                        <td style="width: 38%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 10px 16px; font-size: 13px;">Office / Station</td>
                        <td style="color: #0F172A; font-weight: 600; padding: 10px 16px; font-size: 13px;">${officeLoc}</td>
                    </tr>
                </table>
            </div>

            <!-- STEP 1: Webmail Login -->
            <div style="margin-top: 22px; border: 1px solid #BFDBFE; border-radius: 12px; overflow: hidden; background: #FFFFFF;">
                <div style="padding: 12px 18px; font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: .06em; background: #EFF6FF; color: #1E40AF; border-bottom: 1px solid #BFDBFE;">
                    <span style="display: inline-block; padding: 2px 8px; border-radius: 4px; background: #DBEAFE; color: #1E40AF; margin-right: 6px;">Step 1</span> Access Official Company Webmail (Do this first)
                </div>
                <div style="padding: 16px 18px;">
                    <p style="margin: 0 0 12px 0; font-size: 13px; color: #334155; line-height: 1.5;">
                        Your official corporate mailbox has been provisioned. <strong>Log in here first</strong>, then use the EVC ERP activation link below to create your permanent password.
                    </p>
                    <table style="width: 100%; border-collapse: collapse;">
                        <tr>
                            <td style="width: 38%; color: #64748B; font-weight: 500; padding: 8px 12px; font-size: 13px; border-bottom: 1px solid #F1F5F9;">Webmail URL</td>
                            <td style="color: #1E40AF; font-weight: 600; padding: 8px 12px; font-size: 13px; border-bottom: 1px solid #F1F5F9;"><a href="${safeWebmailUrl}" style="color: #1E40AF; text-decoration: none;">${safeWebmailUrl}</a></td>
                        </tr>
                        <tr>
                            <td style="width: 38%; color: #64748B; font-weight: 500; padding: 8px 12px; font-size: 13px; border-bottom: 1px solid #F1F5F9;">Company Email</td>
                            <td style="color: #0F172A; font-weight: 700; padding: 8px 12px; font-size: 13px; border-bottom: 1px solid #F1F5F9;"><code style="background: #F1F5F9; padding: 3px 8px; border-radius: 4px; font-family: monospace;">${email}</code></td>
                        </tr>
                        <tr>
                            <td style="width: 38%; color: #64748B; font-weight: 500; padding: 8px 12px; font-size: 13px;">Temporary Password</td>
                            <td style="color: #EA580C; font-weight: 700; padding: 8px 12px; font-size: 13px;"><code style="background: #FFF7ED; border: 1px solid #FED7AA; padding: 3px 8px; border-radius: 4px; font-family: monospace;">${safeTempPassword}</code></td>
                        </tr>
                    </table>
                    <div style="text-align: center; margin-top: 16px;">
                        <a href="${safeWebmailUrl}" style="display: inline-block; background-color: #0F172A; color: #FFFFFF !important; text-decoration: none; padding: 12px 28px; border-radius: 10px; font-weight: 700; font-size: 13px;">👉 Log into Webmail</a>
                    </div>
                </div>
            </div>

            <!-- STEP 2: ERP Activation -->
            <div style="margin-top: 22px; border: 1px solid #BBF7D0; border-radius: 12px; overflow: hidden; background: #FFFFFF;">
                <div style="padding: 12px 18px; font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: .06em; background: #F0FDF4; color: #166534; border-bottom: 1px solid #BBF7D0;">
                    <span style="display: inline-block; padding: 2px 8px; border-radius: 4px; background: #DCFCE7; color: #15803D; margin-right: 6px;">Step 2</span> Activate Your EVC ERP Account
                </div>
                <div style="padding: 16px 18px;">
                    <p style="margin: 0 0 10px 0; font-size: 13px; color: #334155; line-height: 1.5;">
                        Once you have accessed your Webmail, activate your account on EVC ERP:
                    </p>
                    <ol style="margin: 10px 0; padding-left: 20px; font-size: 13px; color: #334155; line-height: 1.6;">
                        <li>Open the secure activation link below.</li>
                        <li>Create a strong password for <code style="background: #F1F5F9; padding: 1px 5px; border-radius: 3px;">${email}</code>.</li>
                        <li>Sign in to EVC ERP using your company email and new password.</li>
                        <li>Access EVC ERP anytime at <a href="${safeLoginUrl}" style="color: #F47C20; text-decoration: none; font-weight: 600;">${safeLoginUrl}</a>.</li>
                    </ol>
                    <div style="text-align: center; margin-top: 16px;">
                        <a href="${safeActivationUrl}" style="display: inline-block; background-color: #F47C20; background: linear-gradient(135deg, #F47C20 0%, #FF9A4D 100%); color: #FFFFFF !important; text-decoration: none; padding: 14px 32px; border-radius: 12px; font-weight: 700; font-size: 13px; box-shadow: 0 4px 14px rgba(244, 124, 32, 0.3);">Activate your EVC ERP account &rarr;</a>
                    </div>
                </div>
            </div>

            <!-- Quick Access Links -->
            <div style="margin-top: 24px; padding: 18px; background: #F8FAFC; border: 1px dashed #CBD5E1; border-radius: 10px;">
                <div style="font-size: 12px; font-weight: 700; color: #0F172A; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">📌 Key ERP Modules</div>
                <div style="font-size: 12px; color: #475569; line-height: 1.8;">
                    • <strong>Biometric Attendance Logs:</strong> <a href="${safePortalUrl}/attendance" style="color: #F47C20; text-decoration: none; font-weight: 600;">${safePortalUrl}/attendance</a><br>
                    • <strong>Leave Requests & Approvals:</strong> <a href="${safePortalUrl}/leave" style="color: #F47C20; text-decoration: none; font-weight: 600;">${safePortalUrl}/leave</a><br>
                    • <strong>Task & Objective Board:</strong> <a href="${safePortalUrl}/tasks" style="color: #F47C20; text-decoration: none; font-weight: 600;">${safePortalUrl}/tasks</a><br>
                    • <strong>Weekly Reports:</strong> <a href="${safePortalUrl}/reports/weekly-reports" style="color: #F47C20; text-decoration: none; font-weight: 600;">${safePortalUrl}/reports/weekly-reports</a>
                </div>
            </div>

            <div style="text-align: center; font-size: 13px; color: #64748B; margin-top: 24px; line-height: 1.5;">
                If you experience any difficulties setting up your account, contact ICT Support at <a href="mailto:${ICT_SUPPORT_EMAIL}" style="color: #F47C20; font-weight: 700; text-decoration: none;">${ICT_SUPPORT_EMAIL}</a>.
            </div>
        </div>

        ${getERPFooter("Human Capital & IT Administration", `Dispatched by ${preparedByName} ${preparedByDesignation ? "(" + preparedByDesignation + ")" : ""} — ${preparedByDepartment}`)}
    </div>
</body>
</html>`
}
