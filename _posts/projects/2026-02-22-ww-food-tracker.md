---
title: "WW Food Tracker: Multimodal AI Agents for Nutrition Logging"
date: 2026-02-22
categories:
  - ai
  - python
tags:
  - python
  - ai-agent
  - computer-vision
  - automation
repo: https://github.com/weisser-dev/ww-food-tracker
read_time: true
---

Manual food tracking is tedious. You have to look up every ingredient, estimate portion sizes, and enter everything by hand — which is exactly why most people stop doing it after a few days. The WW Food Tracker takes a different approach: take a screenshot of your meal (from a food delivery app, a recipe page, a restaurant menu, or even a photo of your plate), and let an AI agent do the analysis.

The pipeline starts with a vision model that receives the screenshot and returns a structured description of what's visible: ingredients, portion estimates, preparation method. This unstructured description is then passed through a second step that converts it to a normalized JSON schema: each food item, estimated quantity in grams, and macronutrient estimates. The JSON output is then fed into a skill runner — a lightweight executor that can apply domain-specific logic on top of the structured data, such as calculating Weight Watchers points, comparing against daily goals, or flagging items that exceed a user-defined threshold.

The skill pipeline pattern is what makes this more than a one-shot prompt. Each skill is a small, focused function that takes the normalized JSON and produces a specific output. Skills are composable: you can chain them, run them in parallel, or conditionally activate them based on the content of the previous step. This is a practical implementation of the "tool use" pattern that modern AI agents rely on, applied to a concrete domain.

What I find most interesting about this project from a technical standpoint is how much the quality of the JSON normalization step matters. Vision models are good at describing food, but the structured output needs to be consistent enough for downstream skills to process reliably. Small prompt engineering decisions — how you define the schema, what examples you provide, how you handle ambiguous cases — have a disproportionate effect on the end-to-end quality. Multimodal AI agents are powerful, but the data normalization layer is where most of the real engineering effort lives.
