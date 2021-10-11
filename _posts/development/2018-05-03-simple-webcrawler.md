---
title: "Build a simple WebCrawler (Python)"
categories:
  - development
tags:
  - development
  - python
---

### Prerequisites
To complete this tutorial, you'll need a local development environment for Python 3. You can follow this Tutorial: "[How To Install and Set Up a Local Programming Environment for Python 3](https://www.digitalocean.com/community/tutorial_series/how-to-install-and-set-up-a-local-programming-environment-for-python-3)" to configure everything you need.

[https://github.com/weisser-dev/2048](https://github.com/weisser-dev/2048)

### Step 1 - Install Dependencies
Before we create a new crawler, we must first install the required dependencies. These are the following:
- **Scrapy**
this is our later crawler
```pip install scrapy```
- **BeautifulSoup4**
we need this for parsing the crawled content better
```pip install beautifulsoup4```
- ****Optional***: ***ScrapyElasticSearch**** 
we only need this if we want to connect the crawler with an ElasticSearch Index
```pip install ScrapyElasticSearch```

### Step 2 - Create a new Spider
To create a new crawler / spider we first need a new scrapy project (the most practical thing about scrapy is that it takes a lot of work for us).
```scrapy startproject wiki testcrawler```
Next, we switch to the new folder and generate our crawler:
``` cd testcrawler ```
``` scrapy genspider wiki wikipedia.org ```
Now we have created the crawler" **/testcrawler/wiki/spiders/wikipedia. py**".

If you open this file, you can see the basic structure of a crawler:

     # -*- coding: utf-8 -*-
    import scrapy
    
    
    class WikipediaSpider(scrapy.Spider):
        name = 'wikipedia'
        allowed_domains = ['wikipedia.org']
        start_urls = ['http://wikipedia.org/']
    
        def parse(self, response):
            pass

 - *name* = the name of the crawler
 - *allowed_domains* = an array with the allowed domains
 - *start_urls* = an array with the starting points for the crawler

Theoretically, we can already run it now. However, since no items have been defined yet, it will not give us any data at the moment.
```scrapy crawl wikipedia```

**Optional** *You can enter the parameter "-o" and then enter a filename where you want the crawled results to be stored. This looks like the following:* 
```scrapy crawl wikipedia -o test.json``` 

### Step 3 
Before we can retrieve data from the site by using our crawler, we first have to define which data we want specifically. To do this, we go to the **/testcrawler/wiki/items.py** which has already been generated and add our fields to the WikiItem, which will look like this:

    # -*- coding: utf-8 -*-
    
    # Define here the models for your scraped items
    #
    # See documentation in:
    # http://doc.scrapy.org/en/latest/topics/items.html
    
    import scrapy
    
    
    class WikiItem(scrapy.Item):
        # define the fields for your item here like:
        # name = scrapy.Field()
        title = scrapy.Field()
        content = scrapy.Field()
        

### Step 4
Next, we make sure that our crawler finds the right content.
First we create the method "***createItem()***". This gets our response later. There we create an item of the type "***WikiItem***" which we have to import before.
Afterwards we create a BeautifulSoup Object and give it the crawled content. 
I recommend BeautifulSoup because it takes some work off our hands.

To assign the corresponding content to our WikiItem now, we simply say ***item[' title'] = soup.h1. text***
This will take the first found H1 from Soup and displays only the text. We get this later as a title for our crawled element.

Finally we only have to iterate in the "parse"-method about all contents which have the CSS-ID ***"#content"*** and then pass their data to our method "createItem".
The code for this looks like this:

**/testcrawler/wiki/spiders/wikipedia.py**

    # -*- coding: utf-8 -*-
    import scrapy
    from bs4 import BeautifulSoup
    from wiki.items import WikiItem
    
    class WikipediaSpider(scrapy.Spider):
        name = 'wikipedia'
        allowed_domains = ['wikipedia.org']
        start_urls = ['https://de.wikipedia.org/wiki/Webcrawler']
    
        def createItem(self, response):
            item = WikiItem()
            soup = BeautifulSoup(response.extract(), 'html.parser')
            item['title'] = soup.h1.text
            item['content'] = soup.get_text()
            return item
    
        def parse(self, response):
            responseSelector = scrapy.Selector(response)
            for sectionId, section in enumerate(responseSelector.css('#content')):
                yield self.createItem(section)

**/testcrawler/wiki/items.py**

    # -*- coding: utf-8 -*-
    
    # Define here the models for your scraped items
    #
    # See documentation in:
    # http://doc.scrapy.org/en/latest/topics/items.html
    
    import scrapy
    
    
    class WikiItem(scrapy.Item):
        # define the fields for your item here like:
        # name = scrapy.Field()
        title = scrapy.Field()
        content = scrapy.Field()

If we now execute the crawler with "***scrapy crawl wikipedia -o test.json***" we get the content of the crawled page as Json File.
That's all it takes to build a simple crawler.

### Optional: Put Data into an ElasticSearchIndex
To index our crawled page in our ElasticSearch search we just have to install the plugin "***ScrapyElasticSearch***".
```pip install ScrapyElasticSearch```
And add the following settings at the end of the file in the 
" ***/testcrawler/wiki/settings.py***" :

    ITEM_PIPELINES = {
        'scrapyelasticsearch.scrapyelasticsearch.ElasticSearchPipeline': 500
    }
    ELASTICSEARCH_SERVERS = ['localhost:9200']
    ELASTICSEARCH_INDEX = 'wikipedia_search'
    ELASTICSEARCH_TYPE = 'wiki'
    ELASTICSEARCH_UNIQ_KEY = 'title'
    
If our ElasticSearchServer is now running and can be reached under the following port, Scrapy will automatically index the results (like shown in our test.json).
If you specify such a pipeline, you should make sure that the server is always up and running. Otherwise you should implement an exception handler for the connection timeout to your ElasticSearch Server.

Alternatively, you can also include a query in your crawler that uses the environment variables and then set the settings for the pipeline directly in your crawler. To do this, you have to import "os" at the beginning of the crawler, so we can access the environment variables.
The whole thing could look like this:

    import os
	from scrapy.linkextractors import LinkExtractor
	from scrapy.spiders import Spider, Rule
	from scrapy.selector import Selector
    from bs4 import BeautifulSoup
    from wiki.items import WikiItem
    
    class WikipediaSpider(Spider):
        name = "wikipedia"
        if "ELASTICSEARCH_IP" in os.environ and "ELASTICSEARCH_INDEX" in os.environ:
            custom_settings = {
                'ITEM_PIPELINES': {'scrapyelasticsearch.scrapyelasticsearch.ElasticSearchPipeline': 500},
                'ELASTICSEARCH_INDEX': os.environ['ELASTICSEARCH_INDEX'],
                'ELASTICSEARCH_TYPE': 'ourItemType',
                'ELASTICSEARCH_UNIQ_KEY': 'uid',
                'ELASTICSEARCH_SERVERS': [os.environ['ELASTICSEARCH_IP']]
            }

### Code Example
On my [Github](https://github.com/weisser-dev/testcrawler) you will find the example project below - without the ElasticSearch connection.

Here is a small project that crawls a certain number of Wikipedia pages into an elastic index. In addition, there is a web page for querying the elastic index.
Project: [https://github.com/weisser-dev/wiki-crawler](https://github.com/weisser-dev/wiki-crawler)
ElasticDemoPage: [http://whit-e.com/wiki-crawler-example](http://whit-e.com/wiki-crawler-example) - not 100% responsive.
