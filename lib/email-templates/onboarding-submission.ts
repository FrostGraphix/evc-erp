import { escapeHtml, getERPThemeAwareStyles, getERPHeader, getERPFooter } from "./utils"

export interface OnboardingSubmissionEmailProps {
  applicant: {
    first_name: string
    last_name: string
    department?: string | null
    designation: string
    personal_email: string
    phone_number: string
    employment_type?: string | null
    contract_category_code?: string | null
  }
  reviewUrl?: string
}

export function renderOnboardingSubmissionEmail({ applicant, reviewUrl }: OnboardingSubmissionEmailProps): string {
  const firstName = escapeHtml(applicant.first_name)
  const lastName = escapeHtml(applicant.last_name)
  const dept = escapeHtml(applicant.department || "N/A")
  const designation = escapeHtml(applicant.designation)
  const personalEmail = escapeHtml(applicant.personal_email)
  const phoneNumber = escapeHtml(applicant.phone_number)
  const rawType = applicant.employment_type || "full_time"
  let displayType = rawType.replace("_", " ").replace(/\b\w/g, (c: string) => c.toUpperCase())
  if (rawType === "contract" && applicant.contract_category_code) {
    const codeUpper = applicant.contract_category_code.toUpperCase()
    if (codeUpper === "NYSC") displayType = "NYSC"
    else if (codeUpper === "SIWES") displayType = "SIWES"
    else if (codeUpper === "CTR") displayType = "Contract Staff"
    else if (codeUpper === "NEXTGEN") displayType = "Next-Gen"
    else displayType = applicant.contract_category_code
  }
  const employmentType = escapeHtml(displayType)
  const actionUrl =
    reviewUrl || `${process.env.NEXT_PUBLIC_PORTAL_URL || "https://erp.evcng.com"}/admin/hr/employees`

  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Onboarding Submission - ${firstName} ${lastName}</title>
    ${getERPThemeAwareStyles()}
</head>
<body class="email-bg" style="margin: 0; padding: 24px 12px; background: #F8FAFC; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
    <div class="card-box" style="max-width: 600px; margin: 0 auto; background: #FFFFFF; border-radius: 18px; border: 1px solid #E2E8F0; box-shadow: 0 12px 36px rgba(10, 22, 40, 0.08); overflow: hidden;">
    ${getERPHeader("HR & Recruitment", "New Onboarding Submission", "Candidate application ready for administrative verification")}

    <div style="padding: 32px 28px;">
        <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 16px 0;">Dear HR Team,</p>
        <p class="body-p" style="font-size: 14px; color: #334155; line-height: 1.6; margin: 0 0 20px 0;">A new staff onboarding form has been submitted and is pending your review and qualification check in the Admin Console.</p>
        
        <div style="margin-top: 20px; border: 1px solid #E2E8F0; border-radius: 10px; overflow: hidden; background: #F8FAFC;">
            <div style="padding: 10px 16px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; background: #FFF7ED; color: #EA580C; border-bottom: 1px solid #E2E8F0;">Applicant Dossier</div>
            <table style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Full Name</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${firstName} ${lastName}</td>
                </tr>
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Target Department</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${dept}</td>
                </tr>
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Designation</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${designation}</td>
                </tr>
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Personal Email</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;"><a href="mailto:${personalEmail}" style="color: #F47C20; text-decoration: none;">${personalEmail}</a></td>
                </tr>
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">Phone Number</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px; border-bottom: 1px solid #E2E8F0;">${phoneNumber}</td>
                </tr>
                <tr>
                    <td style="width: 35%; color: #64748B; font-weight: 500; border-right: 1px solid #E2E8F0; padding: 12px 18px; font-size: 13px;">Employment Type</td>
                    <td style="color: #0F172A; font-weight: 600; padding: 12px 18px; font-size: 13px;">${employmentType}</td>
                </tr>
            </table>
        </div>

        <div style="text-align: center; margin-top: 28px; margin-bottom: 8px;">
            <a href="${actionUrl}" 
               style="display: inline-block; background-color: #F47C20; background: linear-gradient(135deg, #F47C20 0%, #FF9A4D 100%); color: #FFFFFF !important; text-decoration: none; padding: 14px 34px; border-radius: 12px; font-weight: 700; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; box-shadow: 0 4px 14px rgba(244, 124, 32, 0.3);">
                Review Application &rarr;
            </a>
        </div>
    </div>
    ${getERPFooter("Human Capital & Talent Acquisition", "Replies to this email are monitored by Admin & HR.")}
    </div>
</body>
</html>
`
}
