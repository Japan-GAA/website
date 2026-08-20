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
  training:  "/photos/training.webp",   // a session in progress
  news:      "",   // fallback thumbnail for posts with no cover image
};

export const COLLAGE = [
  // Three photos: 1 runs full width across the top, 2 and 3 sit side by side
  // beneath it. TODO: replace each alt with a real description.
  { src: "/photos/hero.webp", alt: "Japan GAA players in action" },
  { src: "/photos/collage-1.webp", alt: "Japan GAA" },
  { src: "/photos/collage-3.webp", alt: "Japan GAA" },
  // spare: { src: "/photos/collage-2.webp", alt: "Japan GAA" },
  // spare: { src: "/photos/collage-4.webp", alt: "Japan GAA" },
];

export const SPORT_SHOTS = [
  { src: "/photos/sport-1.webp", alt: "Japan GAA" },   // TODO: describe this photo
  { src: "/photos/sport-2.webp", alt: "Japan GAA" },   // TODO: describe this photo
  { src: "/photos/sport-3.webp", alt: "Japan GAA" },   // TODO: describe this photo
  { src: "/photos/sport-4.webp", alt: "Japan GAA" },   // TODO: describe this photo
];

export const EVENT_SHOTS = [
  { src: "/photos/events-1.webp", alt: "Japan GAA at the St Patrick's Day parade in Yokohama, 2025" },
  { src: "/photos/events-2.webp", alt: "Japan GAA Sports Day, 2025" },
  { src: "/photos/events-3.webp", alt: "The Japan GAA Christmas party, 2025" },
  { src: "/photos/events-4.webp", alt: "Club members at a barbecue by the river" },
];
