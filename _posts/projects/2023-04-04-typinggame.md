---
title: "Building a Browser Typing Game Over a Weekend"
date: 2023-04-04
categories:
  - javascript
tags:
  - javascript
  - game
  - typing
repo: https://github.com/weisser-dev/typinggame
read_time: true
---

Typing speed matters more for developers than most people admit. The bottleneck in programming isn't thinking time — it's rarely typing speed either — but there's a real quality-of-life difference between 60 WPM and 100 WPM when you're spending eight hours a day at a keyboard. I built a browser-based typing game over a weekend partly as a practice tool and partly as an excuse to build a complete, polished game in plain JavaScript without reaching for a framework.

The game mechanics are straightforward: words appear on screen, you type them, they clear, you score points for speed and accuracy. The interesting design decisions are in the details. Word frequency lists matter — a good typing practice tool should weight common words more heavily than rare ones, so you practice the patterns you'll actually use. I used a filtered version of a frequency-ordered English word list, with some developer-specific terms mixed in (variable names, common keywords, method names).

The scoring system rewards sustained accuracy more than raw speed. A streak multiplier increases the points per word as your accuracy stays high, and resets on a typo. This creates the right kind of tension: you're incentivized to be accurate rather than mash keys and correct errors. The visual feedback is immediate — a shake animation on the word for a wrong character, a flash and score pop for a correct completion.

Pure JavaScript with no dependencies was a deliberate constraint. HTML Canvas for the game surface, Web Animations API for the feedback effects, and a straightforward game loop with `requestAnimationFrame`. The codebase is small enough to read in one sitting. If you're learning JavaScript and want a project that covers event handling, DOM manipulation, animation, and basic game state management, a typing game is a good choice — the feedback loop is satisfying and the scope is manageable.
