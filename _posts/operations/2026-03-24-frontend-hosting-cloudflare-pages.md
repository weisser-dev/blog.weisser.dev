---
title: "My Typical Frontend Hosting Setup: Strato + Cloudflare + Pages"
date: 2026-03-24
categories:
  - operations
  - devops
tags:
  - cloudflare
  - hosting
  - frontend
  - strato
  - vite
  - static-site
read_time: true
---

Every frontend project I ship — [agentic-ai.weisser.dev](https://agentic-ai.weisser.dev), [scrumbuddy.org](https://scrumbuddy.org), [cv.weisser.dev](https://cv.weisser.dev) and others — follows the same hosting pattern: domain registered at Strato, DNS managed by Cloudflare, site deployed via Cloudflare Pages. It's free, automatic, and takes about 10 minutes to set up the first time.

## The stack

- **Strato** — domain registrar. That's all it does in this setup.
- **Cloudflare** — DNS, SSL, CDN, and the actual hosting via Cloudflare Pages.
- **GitHub** — source of truth. Every push triggers a build and deploy automatically.
- **Vite** (or any static site generator) — the build tool. Output goes to `dist/`.

## Step 1: Point your Strato domain to Cloudflare

Log in to Strato, go to your domain settings and change the nameservers to the two Cloudflare nameservers assigned to your account. They look like `*.ns.cloudflare.com` — you'll find the exact values in your Cloudflare dashboard under **DNS > Nameservers** after adding the domain there.

In Cloudflare: **Add a site** → enter your domain → choose the free plan → Cloudflare scans your existing DNS records → you confirm and note down the two nameserver addresses → go back to Strato and enter them.

DNS propagation takes a few minutes to a few hours. Once it's done, Cloudflare controls everything.

## Step 2: Create a Cloudflare Pages project

Go to [pages.cloudflare.com](https://pages.cloudflare.com) → **Create a project** → **Connect to Git** → authorize Cloudflare to access your GitHub account → select the repository.

Configure the build settings:

| Setting | Value |
|---|---|
| Branch | `main` |
| Build command | `npm run build` |
| Build output directory | `dist` |

For plain HTML/CSS/JS with no build step, leave the build command empty and set the output directory to `/`.

Click **Save and Deploy**. Cloudflare clones the repo, runs the build, and publishes to a `*.pages.dev` URL in under a minute.

## Step 3: Add your custom domain

In your Pages project, go to **Custom domains** → **Set up a custom domain** → enter your domain (e.g. `agentic-ai.weisser.dev`). Since your domain is already on Cloudflare, it creates the DNS record automatically and provisions SSL via Let's Encrypt within minutes.

That's it. The next `git push` to `main` will automatically trigger a new build and deploy. No CI pipeline to maintain, no server to manage, no bill at the end of the month.

## Why this works well

The thing I like most about this setup is how little there is to think about once it's running. Cloudflare handles SSL renewal, CDN caching, DDoS protection, and deployment all in one place. The free tier is genuinely generous for personal projects and small tools — unlimited bandwidth, 500 builds per month, custom domains included.

The only thing Strato does in this setup is hold the domain registration. If you're registering a new domain, you could also register it directly in Cloudflare and skip the nameserver step entirely — but for domains you already have elsewhere, the nameserver delegation works just as well.

## Built with OpenCode

This post — and the project it documents — was built with [OpenCode](https://opencode.ai), an open-source AI coding agent running in the terminal. OpenCode was used throughout the workshop project for CSS and styling work, structuring and scaffolding the project, and reviewing slide content for accuracy and consistency. Writing a post about a hosting setup and having the underlying project itself be a product of AI-assisted development felt like a fitting way to close the loop.

## Reference

- [dilatchi/cloudflare-static-site-demo](https://github.com/dilatchi/cloudflare-static-site-demo) — a clean tutorial repo that walks through the same steps with screenshots
- [pages.cloudflare.com](https://pages.cloudflare.com)
