import { escapeHtml, getERPThemeAwareStyles, getERPHeader, getERPFooter } from "./utils"

export interface SystemAlertTable {
  heading?: string
  headers: string[]
  rows: string[][]
}

interface SystemAlertEmailProps {
  title: string
  /** Plain-text paragraphs, escaped here. */
  paragraphs: string[]
  tables?: SystemAlertTable[]
}

function renderTable(table: SystemAlertTable): string {
  const cell = "padding:8px 12px;border:1px solid #E2E8F0;font-size:12px;vertical-align:top;text-align:left;"
  const head = table.headers.map((h) => `<th style="${cell}background:#F1F5F9;color:#0F172A;font-weight:700;">${escapeHtml(h)}</th>`).join("")
  const body = table.rows
    .map((row) => `<tr>${row.map((value) => `<td style="${cell}color:#334155;">${escapeHtml(value)}</td>`).join("")}</tr>`)
    .join("")
  const heading = table.heading
    ? `<div style="font-size:14px;font-weight:700;color:#0F172A;margin:20px 0 8px;">${escapeHtml(table.heading)}</div>`
    : ""
  return `${heading}<div style="overflow-x:auto;margin-top:10px;border-radius:8px;border:1px solid #E2E8F0;"><table role="presentation" cellpadding="0" cellspacing="0" style="border-collapse:collapse;width:100%;"><thead><tr>${head}</tr></thead><tbody>${body}</tbody></table></div>`
}

/** Branded operational alert: a red/accent title, paragraphs and optional data tables. */
export function renderSystemAlertEmail({ title, paragraphs, tables = [] }: SystemAlertEmailProps): string {
  return (
    '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">' +
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">' +
    `<title>${escapeHtml(title)}</title>` +
    getERPThemeAwareStyles() +
    '</head><body class="email-bg" style="margin:0;padding:24px 12px;background:#F8FAFC;font-family:-apple-system,BlinkMacSystemFont,\'Segoe UI\',Roboto,Helvetica,Arial,sans-serif;">' +
    '<div class="card-box" style="max-width:720px;margin:0 auto;background:#FFFFFF;border-radius:18px;border:1px solid #E2E8F0;box-shadow:0 12px 36px rgba(10,22,40,0.08);overflow:hidden;">' +
    getERPHeader("System Alert", title, "Critical operational alert from EVC Nig. Ltd. ERP") +
    '<div style="padding:28px 24px;">' +
    paragraphs
      .map((p) => `<p class="body-p" style="font-size:14px;color:#334155;line-height:1.6;margin:0 0 12px;">${escapeHtml(p)}</p>`)
      .join("") +
    tables.map(renderTable).join("") +
    '</div>' +
    getERPFooter("IT Operations & System Infrastructure", "Automated operational dispatch. Urgent issues should be escalated directly to ICT.") +
    '</div></body></html>'
  )
}
