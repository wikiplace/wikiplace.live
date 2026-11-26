# Page types

Every Wikiplace article has a page type that decides its infobox, the fields the editor's form asks for, its categories and its generated lists. Page types are defined by the page-type pages in the vault's `types/` folder ([mia-cx/svartz#360](https://github.com/mia-cx/svartz/issues/360)). This file is the design they start from.

We say "page type", never "template": on Wplace, a template is the overlay image people paint from.

Field kinds: `text`, `number`, `date`, `link` / `links` (to pages, optionally of one type), `choice`, `media` (an upload), `url`, `colour` (a hex code shown as a swatch), `records` (a list of small typed objects), and `wplace-location` (registered by a Wikiplace plugin). Every field is optional unless marked **required**.

A **generated list** is the navbox #360 builds from fields. It lists the pages of a type that link to this page through a field, grouped by another field.

## People and groups

### Painter

A painter's page is their own user page at `users/<handle>`. They write it, and only they commit to it directly. There are no standalone articles about players, so nobody writes a page about someone else; the one exception is public figures such as streamers, who may get a page in `painters/`.

- `wplace name` (text), `wplace id` (text)
- `avatar` (media)
- `flag` (link → Location): the country flag they paint under
- `alliances` (links → Alliance), `communities` (links → Community)
- `painting since` (date)
- `favourite colour` (link → Colour)
- `socials` (records: platform, url)

Generated lists: artworks with them in `artists`, tools they develop, and their wiki edits (from history).

### Alliance

An in-game Wplace alliance.

- `banner` (media), `avatar` (media)
- `hq` (wplace-location)
- `leaders` (links → Painter)
- `founded` (date), `status` (choice: active, inactive, disbanded)
- `communities` (links → Community): where it organises
- `allies`, `rivals` (links → Alliance)

Generated lists: artworks (via `alliance`, grouped by `status`), members (painters via `alliances`), and conflicts it fought in (via `belligerents`).

### Community

A group that paints together outside the in-game alliance system: Discord servers, streamer fanbases, subreddits.

- `platform` (choice: discord, twitch, youtube, reddit, other), `url` (url)
- `leaders` (links → Painter), `size` (number), `languages` (text)
- `founded` (date)
- `alliances` (links → Alliance)

Generated lists: artworks (via `community`), members, and community events (via `participants`).

## The map

### Location

A place on the map: a country, region, city, landmark or stretch of ocean.

- `kind` (choice: country, region, city, landmark, ocean, other) **required**
- `part of` (link → Location)
- `where` (wplace-location)
- `flag` (media): for countries

Generated lists: places inside it (via `part of`, grouped by `kind`), artworks there (via `location`, grouped by `status`), and events and conflicts there.

### Artwork

One artwork on the map.

- `image` (media) **required**, `reference` (media): the overlay image it was painted from
- `where` (wplace-location) **required**, `location` (link → Location)
- `size` (text, such as 120×80), `pixels` (number)
- `alliance` (link → Alliance), `community` (link → Community), `artists` (links → Painter)
- `motifs` (links → Motif)
- `status` (choice: in progress, maintained, griefed, lost, archived) **required**, giving the category "<status> artworks"
- `started`, `finished` (date)
- `restorations` (records: date, by → Alliance or Painter, note)
- `event` (link → Official event or Community event)

## Things that happen

### Official event

An event Wplace runs itself.

- `starts`, `ends` (date) **required**
- `kind` (choice: competition, season, collaboration, maintenance, other)
- `release` (link → Release): the update that brought it
- `rewards` (text), `rules` (text)
- `announcement` (url)

Generated lists: artworks made for it (via `event`).

### Community event

Something that happened because the whole world shares one map: trends, raids, collaborations, migrations, griefing waves.

- `starts`, `ends` (date)
- `kind` (choice: trend, raid, collaboration, migration, griefing, other)
- `locations` (links → Location)
- `participants` (links → Alliance, Community or Painter)
- `outcome` (text)

Generated lists: artworks involved (via `event`).

### Conflict (extends Community event)

A fight over territory between alliances or communities. It inherits every Community event field and appears in Community event lists.

- `belligerents` (records: side, alliances → Alliance, communities → Community, leaders → Painter)
- `front` (links → Location)
- `cause` (text)
- `result` (choice: decisive, stalemate, ceasefire, ongoing), plus `victor` (text, the side's name)
- `artworks lost`, `artworks won` (links → Artwork)

## Wplace itself

A how-to-play wiki and the technical docs for the game.

### Feature

A game mechanic or system: charges, droplets, the palette, flags, alliances, levels, the anti-bot checks. The page's body explains how it works and how to use it.

- `category` (choice: painting, economy, social, map, account, moderation) **required**
- `status` (choice: live, beta, removed)
- `introduced` (link → Release)

Generated lists: releases that changed it (via `features`). The Palette feature page lists every Colour, ordered by `index`.

### Colour

One colour of the Wplace palette.

- `hex` (colour) **required**, `index` (number): its position in the palette
- `tier` (choice: free, premium) **required**
- `price` (number, in droplets): for premium colours
- `introduced` (link → Release)

### Release

One Wplace update, from the official release notes.

- `date` (date) **required**, `version` (text)
- `features` (links → Feature): what it added or changed
- `colours` (links → Colour): colours it added
- `events` (links → Official event)
- `source` (url): the official announcement

### Tool

A userscript, extension, overlay, bot or site made for Wplace.

- `kind` (choice: userscript, extension, overlay, bot, website, app) **required**
- `developers` (links → Painter or Community)
- `platforms` (text), `url` (url), `source` (url), `licence` (text)
- `status` (choice: active, unmaintained, abandoned)
- `flagged by wplace` (choice: no, yes, unknown): whether Wplace's anti-bot checks catch it
- `released` (date), `version` (text)

## Culture

### Motif

A symbol or meme that recurs across the map.

- `image` (media)
- `origin` (text), `first seen` (link → Artwork), `first seen on` (date)
- `related` (links → Motif)

Generated lists: every artwork that uses it (via `motifs`).
