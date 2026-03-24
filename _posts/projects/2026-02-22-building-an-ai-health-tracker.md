---
title: "Building an AI-Powered Health Tracker"
date: 2026-02-22
categories:
  - ai
  - javascript
tags:
  - javascript
  - ai
  - health-tracking
  - personal-project
read_time: true
---

Health data is everywhere and nowhere at the same time. Fitness apps track your workouts, step counters track your movement, nutrition apps track your food, sleep trackers track your recovery — and none of them talk to each other in any meaningful way. The AI health tracker I've been building is an attempt to aggregate all of this into a single view and then apply an LLM to generate insights that go beyond what any single data source can provide.

The architecture is a full-stack JavaScript application: a backend API that connects to various data sources, a normalization layer that translates heterogeneous health data into a consistent schema, a storage layer for historical data, and a frontend that displays aggregated metrics and surfaces AI-generated summaries. The data aggregation is the hardest part — every source has a different API, a different data model, and different refresh rates. Building adapters for each source while keeping the core data model stable requires careful interface design.

The LLM integration sits on top of the normalized data layer. Rather than dumping raw numbers into a prompt, the system pre-computes meaningful derived metrics — weekly trends, personal records, recovery load estimates — and provides those as structured context alongside the raw data. The model is then prompted to act as a knowledgeable fitness coach, synthesizing across all data dimensions to produce a weekly summary: what went well, what the data suggests about recovery and readiness, and specific recommendations for the coming week.

What I've found technically interesting is the challenge of making LLM outputs trustworthy for health applications. The model needs to be grounded in the actual data rather than generating plausible-sounding advice that doesn't reflect the user's real metrics. Prompt engineering for factual grounding — explicitly instructing the model to reference specific data points and not to make claims beyond what the data supports — makes a meaningful difference in output quality. The combination of good data aggregation and careful prompting produces recommendations that feel genuinely personalized rather than generic.
