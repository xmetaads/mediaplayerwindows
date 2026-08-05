# mediaplayerwindows.com

The marketing site for **Media Player Windows**, a media player for Windows 10
and 11.

Static HTML and CSS. No build step, no framework, no JavaScript. Deployed by
Vercel straight from this repository.

```
index.html      landing page
terms.html      Terms of Service      -> /terms
privacy.html    Privacy Policy        -> /privacy
404.html        not-found page
styles.css      the whole design system, in CSS custom properties
vercel.json     cleanUrls + security headers + asset caching
robots.txt      sitemap pointer
sitemap.xml     three URLs
assets/         logo, favicon, screenshot, Open Graph card
```

## Deploying

Vercel needs no configuration beyond connecting the repository:

* **Framework preset:** Other
* **Build command:** none
* **Output directory:** leave empty (the repository root *is* the site)
* **Root directory:** leave empty

`vercel.json` sets `cleanUrls: true`, which is what makes `/terms` and
`/privacy` work without the `.html` suffix. Every internal link relies on that,
so do not remove it.

Then add `mediaplayerwindows.com` (and `www.`) under **Settings → Domains**.

## Before this goes live

These are real blockers, not polish.

1. **Fill in the bracketed values.** `terms.html` and `privacy.html` contain
   `[LEGAL ENTITY NAME]`, `[REGISTERED ADDRESS]`, `[JURISDICTION]`,
   `[CONTACT EMAIL ADDRESS]`, `[EFFECTIVE DATE]` and `[AMOUNT AND CURRENCY]`.
   Search the repository for `[` to find them all.

2. **Delete the two publisher notice boxes.** Each legal page opens with a
   `<div class="notice" id="publisher-todo">` addressed to you, not to visitors.
   Both say so. Remove them once their contents are done.

3. **Have the legal text reviewed.** The substance is accurate for version
   0.1.0 — it was written against the actual source, and the privacy claims are
   checkable — but the wording has not been through a lawyer. Consumer-protection
   law in your markets may override parts of the warranty and liability sections.

4. **Publish a release so the download button works.** Both buttons point at
   `https://github.com/xmetaads/mediaplayerwindows/releases/latest`. Until a
   release exists with `MediaPlayerWindows-0.1.0-Setup.exe` attached, that link
   404s. Either publish it here, or repoint the buttons — there are two
   occurrences in `index.html`.

5. **Decide about Google Fonts.** The site loads Outfit and Work Sans from
   Google, which discloses each visitor's IP address to Google. The Privacy
   Policy says so honestly. Self-hosting the two families removes the issue and
   the disclosure; it is one `@import` in `styles.css`.

## If you add anything that collects data

Analytics, Vercel Web Analytics, a newsletter box, a contact form, a chat
widget — any of these makes section 7 of the Privacy Policy false. Update that
page in the same commit, not afterwards.

## Design system

Generated with the
[ui-ux-pro-max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) skill
for the product type *Video Streaming/OTT*: **Dark Mode (OLED) + Motion-Driven**,
pattern **Hero-Centric + Feature-Rich**, typography **Outfit / Work Sans**,
easing `cubic-bezier(0.16, 1, 0.3, 1)`, radius `16px`, and the style's own rule
of never using pure `#000000`.

Two of the skill's suggestions were deliberately not followed:

* Its palette recommendations for this category are for other industries
  (“academic navy + gold”, “operation orange”). The brand gradient here —
  `#D848D0 → #F050A0 → #F87858` — was measured out of the application's own
  shipped `.ico`, so the site and the product match.
* Its “App Store Style Landing” pattern wants store badges, a QR code and a
  star rating. This is a Windows desktop application with no store presence,
  and inventing ratings or reviews it has not earned was not an option.

Everything on the page is real: the screenshot is a capture of the running
application at 200% display scaling, and every feature listed is one that
exists.
