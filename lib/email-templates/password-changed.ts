import { escapeHtml, getERPThemeAwareStyles, getERPHeader, getERPFooter } from "./utils"

interface PasswordChangedEmailProps {
  userName?: string | null
  userEmail: string
  changeTime: string
  ipAddress?: string | null
}

export function renderPasswordChangedEmail({ userName, userEmail, changeTime, ipAddress }: PasswordChangedEmailProps) {
  const name = escapeHtml((userName || userEmail || "Team Member").trim())
  const email = escapeHtml(userEmail)
  const time = escapeHtml(changeTime)
  const ip = ipAddress ? escapeHtml(ipAddress) : "Unknown IP"

  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Alert: Password Changed</title>
    ${getERPThemeAwareStyles()}
</head>
<body class="email-bg" style="margin: 0; padding: 24px 12px; background: #F8FAFC; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
    <div class="card-box" style="max-width: 600px; margin: 0 auto; background: #FFFFFF; border-radius: 18px; border: 1px solid #E2E8F0; box-shadow: 0 12px 36px rgba(10, 22, 40, 0.08); overflow: hidden;">
        ${getERPHeader("Security Notification", "Password Changed Successfully", "Official security alert for your EVC ERP account")}

        <div style="padding: 32px 28px;">
            <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 16px 0;">
                Hello <strong class="body-strong" style="color: #0F172A;">${name}</strong>,
            </p>
            <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 16px 0;">
                This email confirms that the password for your <strong>EVC ERP</strong> account was updated on <strong>${time}</strong>.
            </p>
            
            <div style="margin-top: 20px; margin-bottom: 20px; border: 1px solid #E2E8F0; background: #F8FAFC; border-radius: 10px; padding: 18px;">
                <div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748B; margin-bottom: 8px; letter-spacing: 0.05em;">
                    Security Summary
                </div>
                <div style="font-size: 13px; color: #0F172A; margin-bottom: 6px;">
                    <strong>Account Email:</strong> ${email}
                </div>
                <div style="font-size: 13px; color: #0F172A; margin-bottom: 6px;">
                    <strong>Time of Change:</strong> ${time}
                </div>
                <div style="font-size: 13px; color: #0F172A;">
                    <strong>Device IP:</strong> ${ip}
                </div>
            </div>

            <div style="border-left: 4px solid #EF4444; background: #FEF2F2; padding: 14px 18px; border-radius: 8px; margin-top: 20px;">
                <p style="font-size: 13px; color: #991B1B; margin: 0; font-weight: 600; line-height: 1.5;">
                    Did not make this change? Please notify ICT Security immediately or reset your credentials at <a href="https://erp.evcng.com/auth/forgot-password" style="color: #DC2626; text-decoration: underline;">https://erp.evcng.com/auth/forgot-password</a>.
                </p>
            </div>
        </div>

        ${getERPFooter("ICT Security & Identity Protection", "Protected by 256-bit enterprise encryption.")}
    </div>
</body>
</html>
  `
}
