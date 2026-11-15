export function escapeHtml(unsafe: string): string {
  if (!unsafe || typeof unsafe !== "string") return ""
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;")
}

export function getERPThemeAwareStyles(): string {
  return `
    <meta name="color-scheme" content="light dark">
    <meta name="supported-color-schemes" content="light dark">
    <style type="text/css">
      :root { color-scheme: light dark; supported-color-schemes: light dark; }
      @media (prefers-color-scheme: dark) {
        .email-bg { background-color: #070D18 !important; }
        .card-box { background-color: #0F172A !important; border-color: rgba(255,255,255,0.1) !important; box-shadow: 0 25px 60px rgba(0,0,0,0.6) !important; }
        .header-bg { background-color: #0B1120 !important; border-bottom-color: rgba(255,255,255,0.08) !important; }
        .header-pill { background-color: rgba(244,124,32,0.18) !important; border-color: rgba(244,124,32,0.35) !important; color: #F9A35E !important; }
        .header-title, .header-title font { color: #FFFFFF !important; }
        .header-sub, .header-sub font { color: #94A3B8 !important; }
        .logo-box {
          background-color: #070D18 !important;
          background-image: linear-gradient(#070D18, #070D18) !important;
          border-color: rgba(255, 255, 255, 0.12) !important;
          box-shadow: 0 4px 14px rgba(0, 0, 0, 0.5) !important;
        }
        .light-logo { display: none !important; }
        .dark-logo {
          display: block !important;
          max-height: none !important;
          overflow: visible !important;
          font-size: 14px !important;
          line-height: normal !important;
        }
        .dark-logo-img { display: block !important; }
        .body-p, .body-p font { color: #CBD5E1 !important; }
        .body-strong, .body-strong font { color: #F8FAFC !important; }
        .footer-bg { background-color: #070D18 !important; border-top-color: rgba(255,255,255,0.06) !important; }
        .footer-text, .footer-text font { color: #64748B !important; }
        .footer-sub, .footer-sub font { color: #475569 !important; }
      }
      [data-ogsc] .email-bg { background-color: #070D18 !important; }
      [data-ogsc] .card-box { background-color: #0F172A !important; border-color: rgba(255,255,255,0.1) !important; }
      [data-ogsc] .header-bg { background-color: #0B1120 !important; border-bottom-color: rgba(255,255,255,0.08) !important; }
      [data-ogsc] .header-title, [data-ogsc] .header-title font { color: #FFFFFF !important; }
      [data-ogsc] .header-sub, [data-ogsc] .header-sub font { color: #94A3B8 !important; }
      [data-ogsc] .logo-box {
        background-color: #070D18 !important;
        background-image: linear-gradient(#070D18, #070D18) !important;
        border-color: rgba(255, 255, 255, 0.12) !important;
      }
      [data-ogsc] .light-logo { display: none !important; }
      [data-ogsc] .dark-logo {
        display: block !important;
        max-height: none !important;
        overflow: visible !important;
      }
      [data-ogsc] .dark-logo-img { display: block !important; }
    </style>
  `;
}

export function getERPHeader(badge: string, title?: string, subtitle?: string): string {
  return `
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" class="header-bg" bgcolor="#F8FAFC" style="background-color:#F8FAFC;border-radius:18px 18px 0 0;padding:32px 28px 24px;text-align:center;border-bottom:1px solid #E2E8F0;border-top:4px solid #F47C20;">
      <tr>
        <td align="center">
          <!-- EVC Official Logo (Fully Theme-Aware Picture + Logo-Box) -->
          <div style="margin-bottom:20px;text-align:center;">
            <table role="presentation" border="0" cellpadding="0" cellspacing="0" align="center" style="margin:0 auto;">
              <tr>
                <td align="center" class="logo-box" bgcolor="#FFFFFF" style="padding:6px 16px;border-radius:14px;background-color:#FFFFFF;background-image:linear-gradient(#FFFFFF, #FFFFFF);border:1px solid #E2E8F0;box-shadow:0 2px 6px rgba(15,23,42,0.04);">
                  <picture>
                    <source srcset="https://raw.githubusercontent.com/FrostGraphix/evc-marketplace/main/public/images/evc-logo-dark.png" media="(prefers-color-scheme: dark)">
                    <img src="https://raw.githubusercontent.com/FrostGraphix/evc-marketplace/main/public/images/evc-logo-light.png" alt="EVC Nig. Ltd." width="130" height="52" class="light-logo" style="display:block;max-width:130px;height:auto;border:0;outline:none;text-decoration:none;" />
                  </picture>
                  <!--[if !mso]><!-->
                  <div class="dark-logo" style="display:none;max-height:0;overflow:hidden;mso-hide:all;font-size:0;line-height:0;">
                    <img src="https://raw.githubusercontent.com/FrostGraphix/evc-marketplace/main/public/images/evc-logo-dark.png" alt="EVC Nig. Ltd." width="130" height="52" class="dark-logo-img" style="display:none;max-width:130px;height:auto;border:0;outline:none;text-decoration:none;" />
                  </div>
                  <!--<![endif]-->
                </td>
              </tr>
            </table>
          </div>
          <div class="header-pill" style="display:inline-block;padding:4px 14px;background-color:#FFF7ED;border:1px solid #FED7AA;border-radius:999px;color:#EA580C;font-size:11px;font-weight:800;letter-spacing:0.12em;text-transform:uppercase;margin-bottom:12px;">
            ${escapeHtml(badge || "EVC Nig. Ltd. • ERP")}
          </div>
          ${title ? `
            <h1 class="header-title" style="margin:0;font-size:22px;font-weight:800;color:#0F172A !important;line-height:1.3;letter-spacing:-0.02em;">
              <font color="#0F172A">${escapeHtml(title)}</font>
            </h1>
          ` : ""}
          ${subtitle ? `
            <p class="header-sub" style="margin:8px 0 0;font-size:13px;color:#475569 !important;line-height:1.6;">
              <font color="#475569">${escapeHtml(subtitle)}</font>
            </p>
          ` : ""}
        </td>
      </tr>
    </table>
  `;
}

export function getERPFooter(footerSystem = "ERP & Operations Workspace", footerNote = "This is an automated administrative notification from EVC Nig. Ltd."): string {
  return `
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" class="footer-bg" bgcolor="#F1F5F9" style="background-color:#F1F5F9;border-radius:0 0 18px 18px;padding:24px 28px;text-align:center;border-top:1px solid #E2E8F0;font-size:12px;color:#64748B;">
      <tr>
        <td align="center">
          <strong class="footer-text" style="color:#0F172A;font-size:13px;">
            <font color="#0F172A">EVC Nig. Ltd.</font>
          </strong><br>
          <span style="color:#EA580C;font-weight:600;font-size:12px;">${escapeHtml(footerSystem)}</span>
          <br><br>
          <i class="footer-sub" style="color:#94A3B8;font-size:11px;">${escapeHtml(footerNote)}</i>
          <div style="margin-top:12px;font-size:11px;color:#94A3B8;">
            &copy; ${new Date().getFullYear()} EVC Nig. Ltd. All rights reserved.
          </div>
        </td>
      </tr>
    </table>
  `;
}
