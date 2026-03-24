---
title: "DevTools Coverage Extractor: Finding Unused JavaScript in Production"
date: 2021-09-02
categories:
  - javascript
  - tools
tags:
  - javascript
  - devtools
  - coverage
  - tooling
repo: https://github.com/weisser-dev/devtools-coverage-extractor
read_time: true
---

Chrome DevTools has a Coverage panel that tells you which lines of CSS and JavaScript are actually executed when a page loads. It's a useful diagnostic tool for identifying dead code and measuring the actual payload you're delivering to users versus what the browser downloads. The devtools-coverage-extractor project extends an existing CSS extraction tool to also handle the JavaScript side, generating a clean report of used and unused JS by file.

The underlying mechanism works through the DevTools Protocol. DevTools instruments the JavaScript engine to track which byte ranges of each script are executed during page load. The coverage data is exported as a JSON report containing, for each script, the URL and a list of executed ranges. The extractor processes this JSON, computes per-file coverage percentages, identifies uncovered functions and code blocks, and outputs a readable report.

The practical value of this kind of analysis is real. Modern web applications commonly ship large JavaScript bundles where 30-50% of the code is never executed on a typical user session. Some of this is inevitable — conditionally loaded features, error handling paths, polyfills for browsers you're already using. But some of it is genuinely dead code that could be removed or code-split into lazy-loaded chunks. The coverage report gives you evidence to prioritize these refactoring efforts rather than guessing.

The project extends an existing CSS coverage tool because the DevTools coverage export format is the same for both CSS and JavaScript — they come from the same API endpoint. The difference is in how you process the results: CSS coverage is straightforwardly about selector usage, while JavaScript coverage requires understanding the bundle structure to map executed byte ranges back to meaningful code units. The extractor handles both in a single pass, which makes it convenient to run a single analysis and get a unified picture of your frontend's actual runtime profile.
