export type PersonaMode = "relax" | "romantic" | "family" | "budget" | "photo" | "foodie";
export type PaceMode = "slow" | "medium" | "fast";

export type ScoringPlace = {
  category: string;
  best_time: string;
  tags: string[];
  duration_min: number;
  popularity_score: number;
  is_free?: boolean;
};

const personaCategoryWeights: Record<PersonaMode, Record<string, number>> = {
  relax: { nature: 4, beach: 4, cafe: 4, viewpoint: 3, activity: 1, mall: 1 },
  romantic: { viewpoint: 5, cafe: 4, beach: 3, historical: 2, mall: 1 },
  family: { nature: 3, beach: 3, activity: 3, museum: 2, food: 1, mall: 4 },
  budget: { market: 4, mall: 3, food: 3, nature: 3, viewpoint: 3, museum: -1 },
  photo: { viewpoint: 5, historical: 3, nature: 3, beach: 2 },
  foodie: { food: 6, cafe: 5, market: 2, mall: 2, viewpoint: 1 },
};

export function getStopsPerDay(mode: PersonaMode, pace: PaceMode): number {
  if (mode === "relax") return pace === "fast" ? 4 : 3;
  if (mode === "photo") return pace === "slow" ? 5 : 6;
  if (mode === "foodie") return pace === "fast" ? 6 : 5;
  if (mode === "family") return pace === "fast" ? 5 : 4;
  if (mode === "romantic") return pace === "fast" ? 5 : 4;
  return pace === "slow" ? 4 : pace === "fast" ? 6 : 5;
}

export function computePlaceScore(
  place: ScoringPlace,
  mode: PersonaMode,
  preferences: string[],
  timeSlot?: "morning" | "day" | "sunset" | "night"
): number {
  const tags = new Set(place.tags ?? []);
  let score = place.popularity_score;

  score += personaCategoryWeights[mode][place.category] ?? 0;
  score += preferences.filter((pref) => tags.has(pref)).length * 8;

  if (timeSlot && place.best_time === timeSlot) score += 4;
  if (mode === "photo" && (tags.has("instagrammable") || tags.has("sunset") || tags.has("sunrise"))) score += 6;
  if (mode === "foodie" && (place.category === "food" || place.category === "cafe")) score += 8;
  if (mode === "family") {
    if (tags.has("family")) score += 5;
    if (place.duration_min > 120) score -= 5;
    if (place.best_time === "night") score -= 5;
  }
  if (mode === "budget") {
    if (tags.has("budget") || place.category === "nature" || place.category === "viewpoint" || place.category === "market" || place.category === "mall") score += 4;
    if (place.is_free) score += 6;
    if (place.category === "museum" && place.popularity_score < 80) score -= 4;
  }
  if (preferences.includes("free") && place.is_free) score += 8;
  if (mode === "relax") {
    if (tags.has("walkable")) score += 4;
    if (tags.has("steep") || tags.has("high_walking")) score -= 6;
  }
  if (mode === "romantic") {
    if (place.category === "viewpoint" || place.best_time === "sunset" || tags.has("sunset")) score += 6;
    if (tags.has("crowded")) score -= 5;
  }

  return score;
}
