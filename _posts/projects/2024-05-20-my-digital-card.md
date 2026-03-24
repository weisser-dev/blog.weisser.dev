---
title: "My Digital Card: A Configurable React Business Card Component"
date: 2024-05-20
categories:
  - typescript
tags:
  - typescript
  - react
  - portfolio
  - card
repo: https://github.com/weisser-dev/my-digital-card
read_time: true
---

Physical business cards are on their way out. Digital ones are still catching up, but most solutions are either SaaS products with subscription fees and vendor lock-in, or static HTML pages that require editing markup every time something changes. I built my-digital-card as a reusable React component that's entirely driven by a JSON configuration object — fork it, change the config, deploy to GitHub Pages in five minutes.

The configuration schema covers everything a digital card needs: name, title, bio, profile image, contact links (GitHub, LinkedIn, email, phone), a list of skills or tags, and optional social links. All of these are optional — the component degrades gracefully if fields are absent. The TypeScript types ensure you'll get a compile error if you mistype a field name, which sounds minor but saves the inevitable "why isn't my GitHub link showing up" debugging session.

Dark and light mode are both fully designed and switch automatically based on `prefers-color-scheme`, with a manual override toggle. The layout is responsive — it collapses cleanly on small screens without needing a separate mobile design. Multilingual content is handled by providing locale-specific values in the config where applicable. The whole thing is a single deployable component with no backend dependencies.

What I learned building this: the constraint of "configured by JSON" is surprisingly clarifying as a design discipline. Every decision about what to include has to be justified by "would a typical developer want this as a config option?" It prevented feature creep and kept the interface small. It also means that when I later rebuilt weisser.dev using this as a base, the migration was trivial — I already had the config format, I just needed to update the values.
