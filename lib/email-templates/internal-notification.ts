import { escapeHtml, getERPThemeAwareStyles, getERPHeader, getERPFooter } from "./utils"
import { type PendingUser } from "./welcome"

interface InternalNotificationEmailProps {
  pendingUser: PendingUser
  preparedBy?: {
    name?: string | null
    designation?: string | null
    department?: string | null
  }
}

export function renderInternalNotificationEmail({ pendingUser, preparedBy }: InternalNotificationEmailProps) {
  const firstName = escapeHtml(pendingUser.first_name)
  const lastName = escapeHtml(pendingUser.last_name)
  const dept = escapeHtml(pendingUser.department)
  const role = escapeHtml(pendingUser.designation)
  const email = escapeHtml(pendingUser.company_email)
  const officeLocation = pendingUser.office_location ? escapeHtml(pendingUser.office_location) : "N/A"
  const phoneNumber = pendingUser.phone_number ? escapeHtml(pendingUser.phone_number) : "N/A"
  const preparedByName = escapeHtml((preparedBy?.name || "Admin and HR Lead").trim())
  const preparedByDesignation = escapeHtml((preparedBy?.designation || "").trim())
  const preparedByDepartment = escapeHtml((preparedBy?.department || "Admin and HR").trim())

  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Employee Onboarding Notification</title>
    ${getERPThemeAwareStyles()}
</head>
<body class="email-bg" style="margin: 0; padding: 24px 12px; background: #F8FAFC; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
    <div class="card-box" style="max-width: 600px; margin: 0 auto; background: #FFFFFF; border-radius: 18px; border: 1px solid #E2E8F0; box-shadow: 0 12px 36px rgba(10, 22, 40, 0.08); overflow: hidden;">
    ${getERPHeader("HR & Management", "New Employee Onboarded", "Official staff onboarding and company mailbox profile")}
    
    <div style="padding: 32px 28px;">
        <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 16px 0;">Dear Management,</p>
        <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 18px 0;">This is an automated notification that a new team member has been onboarded and their official company email has been provisioned. Details below for your awareness.</p>
        
        <div style="margin-top: 20px; border: 1px solid #E2E8F0; border-radius: 10px; overflow: hidden; background: #F8FAFC;">
            <div style="padding: 10px 16px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; background: #F1F5F9; color: #475569; border-bottom: 1px solid #E2E8F0;">Onboarding Dossier</div>
            <table style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Employee Name</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${firstName} ${lastName}</td>
                </tr>
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Department</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${dept}</td>
                </tr>
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Office / Station</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${officeLocation}</td>
                </tr>
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Official Email</td>
                    <td style="color: #EA580C; font-weight: 700; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${email}</td>
                </tr>
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Designation</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${role}</td>
                </tr>
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px;">Phone Number</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px;">${phoneNumber}</td>
                </tr>
            </table>
        </div>
    </div>
    ${getERPFooter("Human Capital & Operations", `Prepared by ${preparedByName} ${preparedByDesignation ? "(" + preparedByDesignation + ")" : ""} — ${preparedByDepartment}`)}
    </div>
</body>
</html>
  `
}
