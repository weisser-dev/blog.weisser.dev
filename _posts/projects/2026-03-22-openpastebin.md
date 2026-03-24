---
title: "OpenPastebin: A Self-Hosted Pastebin with Automatic Expiration"
date: 2026-03-22
categories:
  - javascript
  - tools
tags:
  - open-source
  - pastebin
  - javascript
  - self-hosted
repo: https://github.com/weisser-dev/openpastebin
read_time: true
---

Every developer has reached for a pastebin at some point — to share a log snippet, pass a config file to a colleague, or dump some output during a debugging session. The existing options are either commercial services with opaque data retention policies, ad-supported with tracking, or old open-source projects that haven't been touched in years. OpenPastebin is my attempt to fix that: a clean, modern, self-hosted pastebin you can run yourself in minutes.

The core feature set is deliberately minimal. Paste some text, set an expiration (minutes, hours, days, or never), get a short URL back. No accounts required. The paste expires and is deleted from storage automatically. That's it. The API-first design means every action available in the UI is also available via a plain HTTP call, making it trivially easy to pipe data in from scripts or CI pipelines — `curl -X POST https://your-instance/api/paste --data "content=hello"` and you get a URL back.

Under the hood, the stack is Node.js with a straightforward REST API and a minimal frontend that doesn't require a build step. Storage is handled by a simple key-value approach with TTL support — Redis works well here, but there's also a file-based fallback for setups that don't want to run an additional process. The expiration mechanism relies on the storage layer's native TTL rather than a background cleanup job, which keeps the application code simple and the operations footprint small.

Self-hosting matters for a tool like this more than it might seem. Paste content is often sensitive: API keys accidentally left in a snippet, internal configuration, stack traces with file paths. When you self-host, you control exactly who can read that data and for how long. For teams running their own infrastructure, deploying OpenPastebin behind an internal reverse proxy takes ten minutes and means sensitive paste content never leaves your network. The Docker image is available, configuration is environment variables, and there's no database migration step — a fresh instance is ready to accept pastes immediately.
