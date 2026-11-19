# Wikiplace direction

## What it is for

Wikiplace (wikiplace.live) is the community wiki for Wplace: its artworks, alliances, events and alliance wars, written by the people who make them.

## Where it is heading

- **A real wiki, not a docs site.** People sign in with Google, Discord, GitHub or X, have accounts and user pages, and edit on the site. Moderators review, revert and moderate on the site. Nobody needs a GitHub account.
- **Content lives in git.** The vault in this repository is the source of truth. Edits commit to it, or open pull requests against it, through the wikiplace[bot] GitHub App. The site shows an edit once the deploy that contains it finishes, and the editor follows that progress on the site.
- **Trust is earned and scoped.** Admins promote people by hand, and weighted reputation promotes them automatically. Alliances are groups that own their pages, so members get more trust on their alliance's pages than they have site-wide.
- **Built on Svartz.** Wikiplace uses first-party `@svartz/*` packages and adds no app code that a plugin could own. Svartz PRD [mia-cx/svartz#338](https://github.com/mia-cx/svartz/issues/338) covers accounts, permissions, commit mode, the moderator dashboard, moderation and history.

## Current state (November 2026)

- The domain, the `wikiplace` GitHub org and this repository exist. The pixel-art logo is in `brand/`.
- No vault, site or deploy yet. The community features wait on Svartz PRD #338.

## Decisions

- Git is the only content store. Edits that go live before the deploy were ruled out, because D1-backed content would mean rebuilding search, history and prerendering.
- There's no email and password sign-in, by design.
- Permissions are `namespace:feature:action` grants, set to allow, deny or unset. They're given to actors (accounts, roles, groups, guest, signed-in) on objects (site, vault, folder, page), following Vesta's model.
- User pages live in git at `users/<handle>`. The owner always commits there directly.
- wikiplace[bot] attributes every action to the person who took it: commits are authored as them, and comments and reviews carry a header naming them.
- The GitHub sync uses both webhooks and a reconcile poll.
