---
title: "Wiki Crawler: Indexing Wikipedia into Elasticsearch with Scrapy"
date: 2018-01-28
categories:
  - python
  - tools
tags:
  - python
  - scrapy
  - elasticsearch
  - web-crawler
repo: https://github.com/weisser-dev/wiki-crawler
read_time: true
---

The wiki-crawler project combines two complementary technologies: Scrapy for web crawling and data extraction, and Elasticsearch for indexing and search. Starting from a seed URL on Wikipedia, the crawler follows internal links, extracts page content, cleans the text (stripping navigation elements, footnotes, and HTML artifacts), and indexes each page as a document in Elasticsearch. The end result is a locally searchable version of a slice of Wikipedia.

Scrapy's design is well-suited to this problem. The `Spider` class defines the starting URLs and the parsing logic; the framework handles request scheduling, concurrency, retry logic, and the crawl queue. The `CrawlSpider` subclass adds link extraction rules that automatically generate new requests from links found on each page. For Wikipedia specifically, the rules filter to `/wiki/` paths and exclude special pages, categories, and talk pages that aren't content articles.

The Elasticsearch indexing pipeline is a Scrapy `ItemPipeline` — a processing stage that receives extracted items and does something with them. Each page becomes an Elasticsearch document with fields for the page title, content text, URL, categories, and crawl timestamp. The `elasticsearch-py` client handles the indexing; the pipeline uses bulk indexing to batch multiple documents per request for throughput.

What makes a full-text search index over a Wikipedia subset actually useful is the Kibana interface on top of it. Search by keyword, filter by category, explore related articles through shared category memberships — the combination turns the raw crawl data into something usable. The project grew out of an earlier, smaller testcrawler project and added the full Elasticsearch integration as the meaningful extension. Building your own search index over content you care about is a good project for understanding both web crawling and search technology from the inside.
