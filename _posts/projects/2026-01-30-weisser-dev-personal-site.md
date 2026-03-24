---
title: "Rebuilding My Personal Site as a Configurable Digital Card"
date: 2026-01-30
categories:
  - typescript
tags:
  - typescript
  - react
  - personal-site
  - portfolio
repo: https://github.com/weisser-dev/weisser.dev
read_time: true
---

Personal websites have a tendency to get stale. You build something, it looks good for a while, and then a year later the tech stack feels dated, the content is out of sync with reality, and updating it feels like more work than it's worth. I wanted to break that cycle by building something that's genuinely easy to keep current — a digital business card for weisser.dev that's configurable through a single JSON file.

The stack is TypeScript and React, deployed as a static site. The entire content model — name, tagline, links, skills, contact info — lives in a typed configuration object. Updating the site means editing JSON, not touching components. This might sound like over-engineering for a single-person site, but it's made a real difference in practice: I've updated the content several times since launch without touching a single component file.

Multilingual support was a deliberate design decision. German and English content are both first-class, and the language toggle is persistent across sessions. For a developer based in Germany working on both local and international projects, having both languages available isn't a vanity feature — it's actually useful. The implementation uses a simple context-based i18n approach without a heavy library, since the vocabulary is small and the switching logic is trivial.

Dark mode is implemented via CSS custom properties that respond to the system preference, with a manual toggle that overrides it and saves to localStorage. The design system underneath is minimal: a handful of color tokens, a type scale, and a grid. Nothing that requires a build step to reason about. The result is a site that loads instantly, works without JavaScript for the basic content, and is trivially forkable if someone else wants to use it as a starting point — which is part of why it's public.
