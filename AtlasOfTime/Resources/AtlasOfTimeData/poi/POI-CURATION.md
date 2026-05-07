# Historical POI Curation Rules

This document defines the v1 data contract and editorial rules for year-based historical points of interest (POIs) in AtlasOfTime.

## Scope

POIs are used to show historically important, geographically anchored events for a selected year.

V1 constraints:

- POIs are point-based only
- each POI belongs to one selected year
- each year may contain at most `10` POIs
- a year may contain `0` POIs if no high-signal records meet the standard
- local curated data is the source of truth

## File Structure

Each year should be stored in its own JSON file.

Examples:

- `poi/1789.json`
- `poi/1914.json`
- `poi/1945.json`

Compression may be added later for consistency with the border dataset, but the canonical JSON shape is defined first.

## Canonical Year File Shape

Each year file must have this top-level structure:

```json
{
  "year": 1914,
  "pointsOfInterest": []
}
```

## POI Field Rules

Each POI record must contain:

- `id`
- `year`
- `title`
- `summary`
- `latitude`
- `longitude`
- `category`
- `confidence`
- `relatedCountryIDs`
- `sourceReferences`

### `id`

- stable string identifier
- unique within the full dataset, not just within one year
- preferred format: `{slug}-{year}`

Example:

- `sarajevo-assassination-1914`

### `year`

- must exactly match the enclosing year file
- no ranges in v1

### `title`

- short, neutral, descriptive
- no sensational wording
- should fit comfortably in a marker card title

### `summary`

- concise factual description
- ideally one sentence, maximum two short sentences
- must describe only the event represented by the POI
- no unsourced interpretation

### `latitude` / `longitude`

- must represent a meaningful focal point for the event
- do not use approximate regional centroids for broad events unless there is no better historically defensible point
- if no meaningful point can be assigned, exclude the event from v1

### `category`

Allowed values:

- `battle`
- `war`
- `treaty`
- `politicalEvent`
- `culturalEvent`
- `disaster`
- `other`

### `confidence`

Allowed values:

- `high`
- `medium`
- `low`
- `unknown`

Use:

- `high` when year, event identity, and location are clear
- `medium` when one element is somewhat approximate
- `low` when significant uncertainty remains
- `unknown` only when the record is retained despite incomplete confidence classification

### `relatedCountryIDs`

- use AtlasOfTime country/entity IDs when the event clearly relates to one or more mapped entities
- may be empty if the event is globally relevant but not cleanly tied to a country identity in current data

### `sourceReferences`

- source references should be present whenever possible
- each source should support at least the event identity, year, or location
- records without sources should be rare and should not be the default

## Inclusion Rules

Include a POI only if it is:

- historically significant
- clearly relevant to the selected year
- tied to a meaningful geographic point
- understandable in a short summary
- strong enough to justify one of at most `10` POI slots for that year

## Exclusion Rules

Do not include:

- filler events added only to reach a quota
- vague regional developments without a meaningful point
- duplicate POIs for the same event in the same year
- events that require lines or polygons to be represented honestly
- weakly sourced or speculative records
- long-running processes with no clear year-specific focal event

## Density Rules

- maximum `10` POIs per year
- recommended target for most years: `3` to `8`
- use fewer entries when only a small number of events are truly high-signal

Absence of POIs is preferable to low-quality POIs.

## Source of Truth Policy

- internet research may be used to collect candidate records
- final app data must be locally curated and versioned
- generated text systems may assist with wording, but may not define the canonical dataset

## Validation Expectations

Every year file should eventually be validated for:

- matching `year` values
- unique IDs
- valid coordinates
- valid category values
- valid confidence values
- non-empty title and summary
- no more than `10` POIs per year
