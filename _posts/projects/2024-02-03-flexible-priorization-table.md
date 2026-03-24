---
title: "Building a Flexible Prioritization Table Because I Couldn't Find One I Liked"
date: 2024-02-03
categories:
  - javascript
  - tools
tags:
  - javascript
  - tool
  - productivity
repo: https://github.com/weisser-dev/flexible-priorization-table
read_time: true
---

Prioritization frameworks are everywhere — MoSCoW, RICE, weighted scoring, Kano model. What's less common is a tool that lets you define your own criteria and weights and gives you an interactive table without locking you into someone else's methodology. I built the flexible-priorization-table because the options I found were either too rigid, too complex, or just spreadsheets with formulas that broke when I looked at them wrong.

The core feature is dynamic columns. You define your own criteria — "business value," "technical complexity," "customer impact," whatever fits your context — assign weights, and the table calculates a weighted score for each row automatically. Context menus (right-click on a row or column header) let you add, remove, and reorder rows and columns without leaving the table. This was the interaction pattern that felt most natural — it keeps the editing interface out of the way when you're in evaluation mode.

Drag and drop reordering of rows was an interesting implementation challenge. The native HTML5 drag-and-drop API is serviceable but has some frustrating quirks, especially around the drag ghost image and the visual feedback during a drag operation. I ended up implementing a cleaner version with pointer events that gave more control over the visual state during dragging. Rows snap to their new position on drop, and the weighted scores update instantly.

The tool is a single HTML file with no dependencies and no build step. This is a deliberate choice for productivity tools I use myself: zero friction to open, works offline, nothing to update. The state is serializable to a JSON string you can save and restore. Is it the most sophisticated prioritization tool ever built? No. Is it exactly what I need, available immediately, with no ads and no account? Yes.
