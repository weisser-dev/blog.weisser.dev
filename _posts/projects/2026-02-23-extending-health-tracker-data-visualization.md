---
title: "Extending the Health Tracker: Data Visualization and Trends"
date: 2026-02-23
categories:
  - ai
  - javascript
tags:
  - javascript
  - health
  - data-visualization
  - personal-project
read_time: true
---

Once you have a health data aggregation layer working, the next question is how to display it usefully. Raw numbers in a table answer "what happened" but don't help you understand "is this good or bad" or "where is this heading." The extension I built adds trend charts, weekly summaries, and goal tracking — the visualization layer that turns data into understanding.

For charting, I evaluated a few JavaScript libraries before settling on one that balanced bundle size, API quality, and customizability. The key requirements were: smooth animation on data updates, good mobile touch interaction for pinch-to-zoom on time series, the ability to draw custom annotations (personal records, goal thresholds, notable events), and a clean aesthetic that fits the overall app design. The library's data model also needed to align reasonably well with the normalized health data schema to avoid excessive transformation on every render.

The weekly summary component is the most design-intensive part of the extension. The challenge is information density — there's a lot to say about a week of health data, but a good summary should be scannable in thirty seconds. The design uses a combination of sparklines (tiny inline charts for trend direction), color coding (green/yellow/red for performance relative to goals), and a single highlighted "insight of the week" that calls out the most notable pattern. The ordering of the sections reflects decreasing importance: sleep and recovery first (because they affect everything else), then training load, then nutrition, then step count.

Goal tracking introduced an interesting data modeling question: what is a health goal, exactly? Goals have a target value, a metric, a time period, and a direction (higher is better, lower is better, or stay within a range). They might be weekly targets, monthly targets, or ongoing. And they need to coexist with historical data that was recorded before the goal existed. The schema I landed on treats goals as time-range annotations on metrics, which means the chart layer can shade goal periods differently and the summary layer can calculate progress correctly regardless of when the goal was set.
