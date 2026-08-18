export const SITE = {
  url: "https://japangaa.org",
  name: "Japan GAA",
};

// Every page is declared once, in both languages.
// `key` links the two versions together for the hreflang tags and the toggle.
export const PAGES = [
  { key: "home",     en: "/",                ja: "/ja/",                labelEn: "Home",      labelJa: "ホーム" },
  { key: "training", en: "/training",        ja: "/ja/training",        labelEn: "Training",  labelJa: "練習" },
  { key: "sport",    en: "/gaelic-football", ja: "/ja/gaelic-football", labelEn: "The sport", labelJa: "競技について" },
  { key: "news",     en: "/news",            ja: "/ja/news",            labelEn: "News",      labelJa: "ニュース" },
  { key: "club",     en: "/committee",       ja: "/ja/committee",       labelEn: "The club",  labelJa: "クラブ" },
  { key: "history",  en: "/history",         ja: "/ja/history",         labelEn: "History",   labelJa: "歴史" },
];

export const pathFor = (key, lang) => PAGES.find((p) => p.key === key)?.[lang];
