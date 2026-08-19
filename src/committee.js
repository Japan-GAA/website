// Committee roles. First names only by default — full names are opt-in,
// and anyone who leaves the committee comes off this list.
// Emails are role-based, so they survive a handover. Set `email` once the
// Cloudflare Email Routing addresses are live.
export const COMMITTEE = [
  { roleEn: "Chairperson",            roleJa: "会長",           people: ["Ciaran"] },
  { roleEn: "Vice-chair",             roleJa: "副会長",         people: ["Rintarou"] },
  { roleEn: "Secretary",              roleJa: "書記",           people: ["Andrew"] },
  { roleEn: "Treasurer",              roleJa: "会計",           people: ["Maya"] },
  { roleEn: "Social media",           roleJa: "広報・SNS",      people: ["Fumika", "Amanda"] },
  { roleEn: "Development and events", roleJa: "普及・イベント", people: ["Haruka", "Shinnosuke"] },
];
