---
title: "Searchify: A Facebook Messenger Bot That Proxies Google Search"
date: 2018-01-26
categories:
  - javascript
tags:
  - javascript
  - node.js
  - messenger-bot
  - chatbot
repo: https://github.com/weisser-dev/searchify
read_time: true
---

In 2018, chatbots were still a genuinely new interface paradigm for many users. Facebook Messenger's bot platform had just opened up, and there was a real question about what kinds of interactions were better suited to conversational interfaces than to traditional apps. Searchify was an experiment in one direction: a Messenger bot that takes a search query from the user and returns the top Google search results as a structured message.

The implementation is a Node.js Express server deployed on Heroku. Facebook's Messenger Platform delivers messages to a webhook — an HTTPS endpoint that receives POST requests when a user sends the bot a message. The webhook handler parses the incoming message, calls a Google search scraping module (this was before clean Google Search APIs were widely available), formats the top results as Messenger "generic template" cards (title, description, URL), and sends them back to the user via the Messenger Send API.

The Messenger generic template was the right format for search results — each result becomes a card with a title, a short description, and a button that opens the URL. Messenger rendered these as a horizontally scrollable carousel, which worked surprisingly well for browsing several results quickly. The conversational interaction was just: type what you want to find, receive results. No form to fill out, no new tab to switch to.

Looking back, Searchify is interesting as an artifact of a particular moment in the chatbot hype cycle. The underlying capability (proxying search results) is trivial; the value proposition was purely the interface. The lesson I took from building it was that the interface matters enormously, and that a lot of "chatbot" projects were solving the wrong problem — using conversational UI not because it was better, but because it was new. That said, the bot development experience with Node.js and Express was smooth, and understanding how webhook-based integrations work paid dividends in later projects.
