---
title: "iOS QuickDraw: Machine Learning Doodle Recognition in React"
date: 2024-06-28
categories:
  - typescript
  - ai
tags:
  - typescript
  - react
  - ios
  - game
  - ml
repo: https://github.com/weisser-dev/iOS-quickdraw-react
read_time: true
---

Google's Quick Draw is one of the most publicly accessible machine learning demos ever made — you doodle something, a neural network guesses what it is in real time, and it's surprisingly delightful. I wanted to build a version of it for iOS that felt like a native experience, using React and TypeScript rather than a game engine. The result is a web-based QuickDraw clone that runs comfortably in a mobile browser and handles touch input well enough to be genuinely playable.

The drawing surface is an HTML5 Canvas with touch event listeners rather than mouse events. Getting drawing to feel smooth on mobile requires some care: you need to handle `touchstart`, `touchmove`, and `touchend` events, prevent the default browser scroll behavior during drawing, and smooth the point interpolation so fast strokes don't appear as disconnected dots. I ended up using a simple Bézier curve interpolation between captured points, which makes even quick doodles look reasonably clean.

The ML side uses a pre-trained model converted to TensorFlow.js format, so inference runs entirely in the browser with no server round trip. The model was trained on Google's Quick Draw dataset, which contains tens of millions of labeled doodles across 345 categories. Input to the model is a 28×28 grayscale bitmap generated from the canvas content, which is small enough that the conversion and inference happen in milliseconds. The top predictions are shown in real time as you draw, which creates the same "it guessed it early!" moment that makes the original Google demo satisfying.

TypeScript here was the right choice over plain JavaScript. The data types involved — canvas contexts, touch events, tensor shapes, prediction outputs — benefit from strong typing, and the game state machine (waiting, drawing, guessing, result) is much easier to reason about with discriminated unions. React handled the UI layer around the canvas cleanly. The one thing I'd do differently is move the model loading to a Web Worker to avoid blocking the main thread during initialization — on slower devices, the initial model load is noticeable.
