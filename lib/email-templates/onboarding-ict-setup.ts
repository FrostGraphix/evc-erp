import { escapeHtml, getERPThemeAwareStyles, getERPHeader, getERPFooter } from "./utils"

export interface OnboardingIctSetupEmailProps {
  employee: {
    first_name: string
    last_name: string
    department: string
    designation: string
    company_email: string
    employee_number?: string | null
    office_location?: string | null
  }
  approvedBy?: {
    name?: string | null
    designation?: string | null
    department?: string | null
  }
  employeesUrl?: string
  /** cPanel's reason when ERP tried and failed to create the mailbox itself. */
  automationFailure?: string | null
}

function row(label: string, value: string, last = false) {
  const border = last ? "" : " border-bottom: 1px solid #E2E8F0;"
  return `
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px;${border}">${label}</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px;${border}">${value}</td>
                </tr>`
}

/**
 * Sent to the ICT inbox when HR approves an onboarding application: create the
 * official mailbox, then send the credentials from the employee's record in ERP.
 */
export function renderOnboardingIctSetupEmail({
  employee,
  approvedBy,
  employeesUrl,
  automationFailure,
}: OnboardingIctSetupEmailProps): string {
  const name = `${escapeHtml(employee.first_name)} ${escapeHtml(employee.last_name)}`
  const companyEmail = escapeHtml(employee.company_email)
  const approvedByName = escapeHtml((approvedBy?.name || "Admin and HR Lead").trim())
  const approvedByDesignation = escapeHtml((approvedBy?.designation || "").trim())
  const approvedByDepartment = escapeHtml((approvedBy?.department || "Admin and HR").trim())
  const failureNote = automationFailure
    ? `<div style="margin: 0 0 20px 0; padding: 12px 16px; border: 1px solid #FECACA; background: #FEF2F2; border-radius: 8px; font-size: 13px; color: #991B1B; line-height: 1.5;">EVC ERP attempted to provision this mailbox automatically, but cPanel returned: <strong>${escapeHtml(automationFailure)}</strong>. Please resolve and use <strong>Send Webmail Credentials</strong> to dispatch, or provision manually.</div>`
    : ""
  const actionUrl = escapeHtml(
    employeesUrl || `${process.env.NEXT_PUBLIC_PORTAL_URL || "https://erp.evcng.com"}/admin/hr/employees`
  )

  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Webmail Setup Required - ${name}</title>
    ${getERPThemeAwareStyles()}
</head>
<body class="email-bg" style="margin: 0; padding: 24px 12px; background: #F8FAFC; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
    <div class="card-box" style="max-width: 600px; margin: 0 auto; background: #FFFFFF; border-radius: 18px; border: 1px solid #E2E8F0; box-shadow: 0 12px 36px rgba(10, 22, 40, 0.08); overflow: hidden;">
    ${getERPHeader("ICT Administration", "Webmail Setup Required", "Corporate email provisioning for approved onboarding application")}

    <div style="padding: 32px 28px;">
        <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 16px 0;">Dear ICT Team,</p>
        <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 16px 0;">The onboarding application for <strong class="body-strong" style="color: #0F172A;">${name}</strong> has been approved. Please provision their official corporate mailbox on webmail.</p>
        ${failureNote}
        <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 20px 0;">Once the mailbox exists, open the employee in EVC ERP and use <strong>Send Webmail Credentials</strong> with the temporary password. That sends the employee their onboarding credentials and notifies HR and their department lead.</p>

        <div style="margin-top: 20px; border: 1px solid #E2E8F0; border-radius: 10px; overflow: hidden; background: #F8FAFC;">
            <div style="padding: 10px 16px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; background: #FFF7ED; color: #EA580C; border-bottom: 1px solid #E2E8F0;">Mailbox Details</div>
            <table style="width: 100%; border-collapse: collapse;">${row("Mailbox to Create", `<strong style="color: #EA580C;">${companyEmail}</strong>`)}${row("Employee Name", name)}${row(
              "Employee ID",
              employee.employee_number ? escapeHtml(employee.employee_number) : "N/A"
            )}${row("Department", escapeHtml(employee.department))}${row("Designation", escapeHtml(employee.designation))}${row(
              "Office / Room",
              employee.office_location ? escapeHtml(employee.office_location) : "N/A",
              true
            )}
            </table>
        </div>

        <div style="text-align: center; margin-top: 28px; margin-bottom: 8px;">
            <a href="${actionUrl}"
               style="display: inline-block; background-color: #0F172A; color: #FFFFFF !important; text-decoration: none; padding: 14px 34px; border-radius: 12px; font-weight: 700; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">
                Open Employees in ERP &rarr;
            </a>
        </div>
    </div>
    ${getERPFooter("Human Capital & IT Provisioning", `Approved by ${approvedByName} ${approvedByDesignation ? "(" + approvedByDesignation + ")" : ""} — ${approvedByDepartment}`)}
    </div>
</body>
</html>
`
}
