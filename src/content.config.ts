import { defineCollection, z } from "astro:content";
import { glob } from "astro/loaders";

const news = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/content/news" }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    cover: z.string().optional(),
    // true for the imported Squarespace newsletters, false/absent for new posts
    archived: z.boolean().default(false),
  }),
});

export const collections = { news };
