import { getCollection } from "astro:content";

// Language is decided by where the file lives, not by frontmatter:
//   src/content/news/foo.md      -> English  (or bilingual, if archived)
//   src/content/news/ja/foo.md   -> Japanese
// A Japanese post is paired with its English one simply by sharing a filename.

export const slugOf = (id: string) => id.replace(/^ja\//, "");
export const isJa   = (id: string) => id.startsWith("ja/");

const byDate = (a: any, b: any) => b.data.date.valueOf() - a.data.date.valueOf();

export async function newsFor(lang: "en" | "ja") {
  const all = await getCollection("news");
  return all
    .filter((p) => {
      if (lang === "ja") return isJa(p.id) || p.data.archived;
      return !isJa(p.id);            // English posts + bilingual archive
    })
    .sort(byDate);
}

// URL a post should live at
export const urlFor = (id: string) =>
  isJa(id) ? `/ja/news/${slugOf(id)}` : `/news/${id}`;

// Does a counterpart exist in the other language?
export async function counterpart(id: string) {
  const all = await getCollection("news");
  const slug = slugOf(id);
  const want = isJa(id) ? slug : `ja/${slug}`;
  return all.find((p) => p.id === want) ?? null;
}
