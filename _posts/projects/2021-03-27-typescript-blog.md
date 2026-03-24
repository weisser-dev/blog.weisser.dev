---
title: "TypeScript Blog: An Early Experiment Before Jekyll"
date: 2021-03-27
categories:
  - typescript
  - javascript
tags:
  - typescript
  - blog
  - css
repo: https://github.com/weisser-dev/typescript-blog
read_time: true
---

Before settling on a Jekyll-based approach for this blog, I experimented with building a TypeScript-powered blog from scratch. The experiment lived in the typescript-blog repository, and while I ultimately didn't ship it as my primary blog, it was a useful exercise in understanding what a blog actually needs and what the tradeoffs of different approaches are.

The TypeScript blog was a single-page application that loaded blog posts from markdown files, converted them to HTML client-side, handled routing without a server, and rendered them with a custom template. TypeScript provided type safety for the data model (post metadata, frontmatter schema) and the rendering pipeline. The CSS was custom — no framework, just a clean typographic foundation with a focus on readability.

What I learned from building it: static site generators exist for good reasons. The things that seem easy when you start — RSS feed generation, pagination, sitemap creation, clean URLs, build performance at scale — are all solved problems in Jekyll, Eleventy, or Hugo. Writing them from scratch means reinventing solutions that have been refined over years. Unless you have genuinely unusual requirements, rolling your own SSG is usually a way to spend time that would be better spent writing content.

The TypeScript skills I developed here weren't wasted, though. Understanding how markdown parsing and HTML rendering work at a lower level made it easier to configure and extend Jekyll when I eventually adopted it. And the CSS from the TypeScript blog informed the typography choices on this current site. Sometimes the detour teaches you things the direct path wouldn't.
