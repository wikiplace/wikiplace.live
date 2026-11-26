# Wikiplace direction

## What it is for

Wikiplace (wikiplace.live) is the community wiki for Wplace: its artworks, alliances, events and alliance wars, written by the people who make them.

## Where it is heading

- **A real wiki, not a docs site.** People sign in with Google, Discord, GitHub or X, have accounts and user pages, and edit on the site. Moderators review, revert and moderate on the site. Nobody needs a GitHub account.
- **Content lives in git.** The vault in this repository is the source of truth. Edits commit to it, or open pull requests against it, through the wikiplace[bot] GitHub App. The site shows an edit once the deploy that contains it finishes, and the editor follows that progress on the site.
- **Trust is earned and scoped.** Admins promote people by hand, and weighted reputation promotes them automatically. Alliances are groups that own their pages, so members get more trust on their alliance's pages than they have site-wide.
- **Built on Svartz.** Wikiplace uses first-party `@svartz/*` packages and adds no app code that a plugin could own. Svartz 2.5.0 ships the community-wiki packages from [mia-cx/svartz#338](https://github.com/mia-cx/svartz/issues/338) (accounts, permissions, commit mode, the moderator dashboard, moderation and history). PRD [mia-cx/svartz#360](https://github.com/mia-cx/svartz/issues/360) covers the article format: page types, notices, wiki callouts, generated navboxes and uploads.
- **Articles are MediaWiki, modernised.** Page types drive the infoboxes and the editor's forms: Painter (a user's own page), Alliance, Community, Location, Artwork, Official event, Community event, Conflict (extends Community event), Feature, Colour, Release, Tool and Motif. Their fields are in [docs/page-types.md](docs/page-types.md).
- **Wikiplace is also the how-to-play wiki for Wplace**: Features, the full palette, release notes and tools. Notices are calm banners. Navboxes generate themselves from fields, so an alliance page lists its artworks without upkeep.
- **An interactive map with timelapses** comes later as its own plugin. It renders archived map data that the community crowdsources through Caelestis, a scraper and an incremental archive. It adds a map callout and the Wplace location field kind.

## Current state (November 2026)

- The domain, the `wikiplace` GitHub org and this repository exist. The pixel-art logo is in `brand/`.
- Svartz 2.5.0 publishes the community-wiki packages from [mia-cx/svartz#338](https://github.com/mia-cx/svartz/issues/338): `@svartz/theme-wiki`, `@svartz/auth`, `@svartz/plugin-submissions`, `@svartz/plugin-moderation`, `@svartz/plugin-history` and `@svartz/plugin-annotations`.
- Still open upstream in `mia-cx/svartz`: [mia-cx/svartz#405](https://github.com/mia-cx/svartz/issues/405) tracks small non-blocking gaps left after #338, and [mia-cx/svartz#360](https://github.com/mia-cx/svartz/issues/360) covers page types, notices, wiki callouts, generated navboxes and R2 uploads.
- No vault, site or deploy in this repository yet. The site is unblocked to start on Svartz 2.5.0.

## Decisions

- Git is the only content store. Edits that go live before the deploy were ruled out, because D1-backed content would mean rebuilding search, history and prerendering.
- There's no email and password sign-in, by design.
- Permissions are `namespace:feature:action` grants, set to allow, deny or unset. They're given to actors (accounts, roles, groups, guest, signed-in) on objects (site, vault, folder, page), following Vesta's model.
- User pages live in git at `users/<handle>`. The owner always commits there directly.
- Painters are the users: a painter's article is their own user page. Nobody writes standalone articles about other players, except public figures such as streamers.
- We say "page type", never "template", because on Wplace a template is the overlay image people paint from.
- wikiplace[bot] attributes every action to the person who took it: commits are authored as them, and comments and reviews carry a header naming them.
- The GitHub sync uses both webhooks and a reconcile poll.
- Everyone edits on the site, so Obsidian compatibility doesn't shape the format. Template fields are flat, typed frontmatter, because templates, categories, navboxes and search can query a field by name.
- Page-wide notices go in frontmatter (`notices:`). A callout with a notice's name flags a single section.
- Uploads live in R2, not git. Workers static assets cap each file at 25 MiB and a deploy at 20,000 files, and a file in git stays in its history, so a takedown would need a history rewrite.
