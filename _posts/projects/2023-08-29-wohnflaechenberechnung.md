---
title: "Wohnflächenberechnung: Automating German Living Area Calculations"
date: 2023-08-29
categories:
  - javascript
  - tools
tags:
  - javascript
  - tool
  - germany
  - real-estate
repo: https://github.com/weisser-dev/wohnflaechenberechnung
read_time: true
---

In Germany, calculating the legally recognized living area (Wohnfläche) of a property is not as simple as measuring rooms and adding up the square meters. The Wohnflächenverordnung (WoFlV) defines specific rules: full-height areas count at 100%, areas under a sloped ceiling between 1m and 2m height count at 50%, areas under 1m height don't count at all. Balconies and terraces typically count at 25% or 50% depending on their quality. When you're selling or renting a property, getting this calculation wrong has legal implications.

The existing solutions for this were either expensive property management software with a learning curve, or manual calculation in a spreadsheet that was error-prone and hard to share. I built a simple JavaScript tool that walks through each room, lets you specify the area and any sloped ceiling portions, and calculates the correct Wohnfläche automatically according to the standard rules.

The UI is a form-based wizard: add rooms one by one, categorize each space, specify the full-area portion and the partial-height portions separately. The calculation engine applies the WoFlV multipliers, accumulates the weighted areas, and presents a breakdown that shows exactly how the total was computed. The output is clear enough to include in a property listing or hand to a notary without needing additional explanation.

Niche tools like this are an underappreciated category of software project. The audience is small — not every developer needs to calculate German living area — but within that audience, the need is real and the existing solutions are poor. Building something that solves a concrete problem in a specific domain, even a small one, is a legitimate use of a weekend afternoon. It also forced me to actually read the Wohnflächenverordnung carefully, which turns out to be a pleasingly precise piece of German administrative writing.
