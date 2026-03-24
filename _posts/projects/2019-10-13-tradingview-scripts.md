---
title: "TradingView Pine Script: Forecasting Bitcoin with Custom Indicators"
date: 2019-10-13
categories:
  - tools
tags:
  - trading
  - bitcoin
  - pinescript
  - tradingview
repo: https://github.com/weisser-dev/tradingview_scripts
read_time: true
---

Pine Script is TradingView's proprietary scripting language for writing custom technical indicators and strategies. It's a domain-specific language that runs against historical price data and can draw overlays and subplots on charts. The tradingview_scripts repository is a collection of indicators I wrote to experiment with Bitcoin price forecasting — combining classic technical analysis signals with some custom logic.

The indicators in the collection cover a few different approaches. Trend-following indicators calculate various moving average crossovers and Bollinger Band states to identify the prevailing trend direction. Momentum indicators use RSI and MACD with custom signal lines and divergence detection. The more experimental ones attempt to identify recurring pattern shapes in price action using statistical comparisons to historical price windows.

Pine Script has a distinctive execution model that takes some getting used to. Scripts are applied to a price series and execute once per bar, with access to the current bar's values and history via indexed arrays. The language is purely functional in this sense — you can't maintain arbitrary state between bars without explicit `var` declarations, and the execution model prevents certain classes of look-ahead bias. This constraint is actually good for technical analysis work, because it forces you to be explicit about what information your indicator uses.

The honest assessment of this work is that no technical indicator reliably forecasts Bitcoin price over the medium term. The value of the exercise was in the Pine Script skill itself and in developing a clearer understanding of why purely technical approaches are limited for cryptocurrency markets. The indicators have some value as visual tools for identifying price structure, but anyone using them for actual trading should do so with appropriate skepticism. Building them was a good programming exercise at the intersection of a domain I found interesting.
