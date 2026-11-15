import { escapeHtml, getERPThemeAwareStyles, getERPHeader, getERPFooter } from "./utils"

const ACCOUNTS_EMAIL = process.env.ORG_ACCOUNTS_EMAIL || "accounts@evcng.com"

export interface PayslipEmailProps {
  fullName: string
  periodName: string
  payDate: string
  /** Whether the attached PDF is password-protected. When true, the body explains the format — never the literal value. */
  protected?: boolean
}

/**
 * Cover note for the payslip email.
 *
 * Deliberately carries NO salary figures and NO literal password. The
 * breakdown lives in the attached PDF; the password (the recipient's own staff
 * ID) is something they already know, so the body only states the format.
 */
export function renderPayslipEmail({
  fullName,
  periodName,
  payDate,
  protected: isProtected,
}: PayslipEmailProps): string {
  const name = escapeHtml((fullName || "").split(" ")[0] || "Colleague")
  const period = escapeHtml(periodName)
  const date = escapeHtml(payDate)
  const accounts = escapeHtml(ACCOUNTS_EMAIL)

  const passwordBlock = isProtected
    ? `
        <div style="margin-top: 20px; border: 1px solid #FED7AA; border-radius: 10px; overflow: hidden; background: #FFF7ED;">
            <div style="padding: 10px 16px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; background: #FFEDD5; color: #EA580C; border-bottom: 1px solid #FED7AA;">Opening the attachment</div>
            <table style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td style="width: 40%; color: #9A3412; font-weight: 500; border-right: 1px solid #FED7AA; padding: 10px 16px; font-size: 13px;">Document Password</td>
                    <td style="color: #431407; font-weight: 700; padding: 10px 16px; font-size: 13px;">Your Staff ID (as shown on your ID card / payslip)</td>
                </tr>
            </table>
        </div>
        <p style="font-size: 12px; color: #64748B; line-height: 1.5; margin-top: 10px;">Enter it exactly as printed, including the slashes — e.g. EVC/2025/038.</p>`
    : ""

  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payslip - ${period}</title>
    ${getERPThemeAwareStyles()}
</head>
<body class="email-bg" style="margin: 0; padding: 24px 12px; background: #F8FAFC; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
    <div class="card-box" style="max-width: 600px; margin: 0 auto; background: #FFFFFF; border-radius: 18px; border: 1px solid #E2E8F0; box-shadow: 0 12px 36px rgba(10, 22, 40, 0.08); overflow: hidden;">
    ${getERPHeader("Payroll & Accounts", "Your Payslip is Ready", `Confidential salary statement for ${period}`)}
    
    <div style="padding: 32px 28px;">
        <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 16px 0;">Dear <strong class="body-strong" style="color: #0F172A;">${name}</strong>,</p>
        <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 18px 0;">Please find attached your payslip for <strong class="body-strong" style="color: #0F172A;">${period}</strong>. It sets out your official earnings, statutory deductions, and net compensation for the cycle.</p>

        <div style="margin-top: 20px; border: 1px solid #E2E8F0; border-radius: 10px; overflow: hidden; background: #F8FAFC;">
            <div style="padding: 10px 16px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; background: #F1F5F9; color: #475569; border-bottom: 1px solid #E2E8F0;">Payslip Details</div>
            <table style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td style="width: 40%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 16px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Pay Period</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 16px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${period}</td>
                </tr>
                <tr>
                    <td style="width: 40%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 16px; font-size: 13px;">Disbursement Date</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 16px; font-size: 13px;">${date}</td>
                </tr>
            </table>
        </div>
        ${passwordBlock}

        <p style="font-size: 12px; color: #64748B; line-height: 1.5; margin-top: 20px;">
          Please treat this document with strict confidentiality. If any variance requires clarification, notify Finance within seven (7) business days.
        </p>

        <div style="text-align: center; font-size: 13px; color: #64748B; margin-top: 24px; line-height: 1.5;">
            Questions about your payslip? Reach Accounts at <a href="mailto:${accounts}" style="color: #F47C20; font-weight: 700; text-decoration: none;">${accounts}</a>.
        </div>
    </div>
    ${getERPFooter("Payroll & Financial Operations", `Confidential employee correspondence. Direct questions to ${accounts}.`)}
    </div>
</body>
</html>`
}
