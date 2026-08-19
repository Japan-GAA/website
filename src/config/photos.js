// Photographs used across the site.
// Put the file in public/photos/ and name it here. Leave "" and the page
// simply renders without a photo — nothing breaks.
//
// To add one:
//   cp archive/images-web/<file>.webp public/photos/history.webp
//   then set history: "/photos/history.webp" below.
export const PHOTOS = {
  // Homepage mosaic — up to 4 photos, shown top-left, top-right,
  // bottom-right (tall), bottom-left. Mix them up: a men's team shot, a
  // ladies' team shot, an action shot, and something social.
  // Fewer than 4 is fine; 0 falls back to the goalposts graphic.
  sport:     "",   // someone soloing / catching — the explainer page
  history:   "/photos/history.webp",   // an old team photo
  committee: "",   // committee group shot
  training:  "",   // a session in progress
  news:      "",   // fallback thumbnail for posts with no cover image
};

export const COLLAGE = [
  // Reorder these freely — position 1 is tall on the left, 2 is top-right,
  // 3 is tall on the bottom-right, 4 is bottom-left.
  // TODO: replace each alt with a real description of that photo.
  { src: "/photos/collage-1.webp", alt: "Japan GAA" },
  { src: "/photos/collage-2.webp", alt: "Japan GAA" },
  { src: "/photos/collage-3.webp", alt: "Japan GAA" },
  { src: "/photos/hero.webp", alt: "Japan GAA players in action" },
  // spare: { src: "/photos/collage-4.webp", alt: "Japan GAA" },
];
