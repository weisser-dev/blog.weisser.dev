---
title: "A Multilingual, Configurable Resume App in TypeScript"
date: 2026-01-30
categories:
  - typescript
tags:
  - typescript
  - react
  - resume
  - multilingual
read_time: true
---

There's a category of developer who has built their own resume app, and I've become one of them. The practical motivation was concrete: I work in a bilingual professional context, maintain separate German and English versions of my CV, and found the update-and-keep-in-sync workflow between two documents genuinely painful. A single TypeScript application with locale-switching solves the problem by making both languages first-class, not afterthoughts.

The content model is fully JSON-driven. Personal information, professional experience, education, skills, certifications, publications, and languages all live in a typed TypeScript configuration object. Each text field that differs between locales holds a locale map rather than a string. The React components are locale-aware: they receive the active locale from context and render the appropriate string. Adding a new locale is a matter of adding keys to the configuration — the component layer doesn't need to change.

Automatic theme detection uses `window.matchMedia('(prefers-color-scheme: dark)')` with a listener that updates the theme when the system preference changes. A manual toggle overrides the automatic detection and stores the preference in localStorage. The CSS is custom properties-based — the entire theme is a handful of color tokens applied to the `:root`, and switching themes is a single class change on `<html>`. This approach is simpler and faster than a styled-components theme or a CSS-in-JS solution for a project with a clear, constrained color system.

The question of why build your own CV app rather than use a template is worth addressing directly. The answer isn't that the technology is impressive (it isn't) or that it takes less time than a Word document (it doesn't, initially). The answer is maintainability over time. Once the app is built, updating the content is fast and reliable, the output is consistent across locales, the print stylesheet works, and adding a section or field takes minutes rather than reformatting a document. For a CV you intend to keep current for years, that ongoing maintenance cost difference is worth the upfront investment.
