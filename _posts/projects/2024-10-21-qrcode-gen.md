---
title: "qrcode-gen: The Value of Building Your Own Simple Tools"
date: 2024-10-21
categories:
  - javascript
  - tools
tags:
  - html
  - qrcode
  - tool
repo: https://github.com/weisser-dev/qrcode-gen
read_time: true
---

QR code generators exist by the dozens. Search engines return pages of them. So why build another one? The honest answer is that I wanted one I trusted — no ads, no tracking pixels, no "sign up to download in high resolution," no data being sent to a third-party server to generate what is, fundamentally, a math operation that can happen entirely in the browser.

The implementation is deliberately minimal: an HTML page, a small JavaScript QR code library, a text input, and a canvas element. Enter your content, get a QR code. The generation happens client-side using a well-tested library that handles the Reed-Solomon error correction and the various QR versions automatically. There's no backend, no API call, no server. The entire tool is a single HTML file that you can download and run from your filesystem if you want.

I use it constantly for things I don't want going through a commercial service: internal URLs, Wi-Fi credentials for guests, links I'm sharing at events where I want to know the QR code generator isn't logging what I'm encoding. It's also useful for testing — when you're building something that involves QR codes, having a local generator that's fast and doesn't add latency is genuinely convenient.

The deeper point is about the economics of building small tools. This took maybe two hours including the UI polish. It saves me from using third-party tools multiple times a week. Over any reasonable time horizon, building it was worth it — and I have exactly the tool I want, with exactly the privacy properties I care about, with zero ongoing maintenance burden. Not every project needs to be ambitious. Sometimes the right project is just the small, useful thing you needed and couldn't find.
