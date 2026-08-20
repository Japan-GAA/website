export const SITE = {
  url: "https://japangaa.org",
  name: "Japan GAA",
};

// Every page is declared once, in both languages.
// `key` links the two versions together for the hreflang tags and the toggle.
export const PAGES = [
  { key: "home",     en: "/",                ja: "/ja/",                labelEn: "Home",      labelJa: "ホーム" },
  { key: "training", en: "/training",        ja: "/ja/training",        labelEn: "Training",  labelJa: "練習" },
  { key: "events",   en: "/events",          ja: "/ja/events",          labelEn: "Events",    labelJa: "イベント" },
  { key: "sport",    en: "/gaelic-football", ja: "/ja/gaelic-football", labelEn: "The sport", labelJa: "競技について" },
  { key: "news",     en: "/news",            ja: "/ja/news",            labelEn: "News",      labelJa: "ニュース" },
  { key: "club",     en: "/committee",       ja: "/ja/committee",       labelEn: "The club",  labelJa: "クラブ" },
  { key: "jerseys",  en: "/jerseys",         ja: "/ja/jerseys",         labelEn: "Jerseys",   labelJa: "ジャージ" },
  { key: "history",  en: "/history",         ja: "/ja/history",         labelEn: "History",   labelJa: "歴史" },
];

export const pathFor = (key, lang) => PAGES.find((p) => p.key === key)?.[lang];

// Top-level navigation. A group with more than one child becomes a dropdown.
export const NAV = [
  { labelEn: "Events",    labelJa: "活動",       children: ["training", "events"] },
  { labelEn: "The sport", labelJa: "競技について", children: ["sport"] },
  { labelEn: "News",      labelJa: "ニュース",   children: ["news"] },
  { labelEn: "The club",  labelJa: "クラブ",     children: ["club", "history"] },
  { labelEn: "Jerseys",   labelJa: "ジャージ",   children: ["jerseys"] },
];
