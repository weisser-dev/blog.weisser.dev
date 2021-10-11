---
title: "Build a Facebook Messenger Bot (Node.js)"
categories:
  - development
tags:
  - development
  - node.js
---

## 🤖 Build your own  Messenger-Bot

Messenger bots uses a web server to process messages it receives or to figure out what messages to send. You also need to have the bot be authenticated to speak with the web server and the bot approved by Facebook to speak with the public.

If you want to see a working messenger bot, jump to the end of the article there and I'll show you one of my bots.

### Prerequisites
Our messenger bot is written in [Node.js](https://nodejs.org/en/), so it is important (for the local environment) to install Node.js and recommend to use an IDE with syntax highlighting for Javascript (e. g. using [Sublime](https://www.sublimetext.com/)) 

### Step 1 - Install Heroku-CLI

This guide refers to how to run the Messenger bot on a Heroku server. 
Therefore it is important that we first [register](https://signup.heroku.com/) at Heroku and then install their CLI - https://devcenter.heroku.com/articles/heroku-cli.

Why the instructions refer to a Heroku server? Now quite simply, Facebook expects an https connection for every messenger bot to make sure that the connection is encrypted. Heroku offers us exactly that, and it is also possible to run several WebApps for free. 

### Step 2 - Create Node.js Project

Next we have to create a new Node. js project for our bot. To do this, we create a folder somewhere and enter the following command there:
    
    npm init
    
### Step 3 - Additional Dependencies    
Now we install the additional Node dependencies. 
express = is needed for the server
request = is needed for sending out messages
body-parser = is needed to process messages.
    
    npm install express request body-parser --save
    
### Step 4 - Create the Index.js
Now we create with the most important file of our bot, the index.js. We copy the following content into it

   ``` javascript
        'use strict'
        
        const express = require('express')
        const bodyParser = require('body-parser')
        const request = require('request')
        const app = express()
    
        app.set('port', (process.env.PORT || 5000))
    
        // Process application/x-www-form-urlencoded
        app.use(bodyParser.urlencoded({extended: false}))
    
        // Process application/json
        app.use(bodyParser.json())
    
        // Index route
        app.get('/', function (req, res) {
        	res.send('Hello world, I am a chat bot')
        })
    
        // for Facebook verification
        app.get('/webhook/', function (req, res) {
        	if (req.query['hub.verify_token'] === 'very_awesome_verify_token') {
        		res.send(req.query['hub.challenge'])
        	}
        	res.send('Error, wrong token')
        })
    
        // Spin up the server
        app.listen(app.get('port'), function() {
        	console.log('running on port', app.get('port'))
        })
   ```

### Step 5 - Commit & Push to Heroku
First we make a file called Procfile and copy this. We need this file so that Heroku knows the starting point of our bot.
File Content:

    web: node index.js
After that, we commit all the code with Git and create a new Heroku instance, then we push the code to the cloud.

    git init
    git add .
    git commit --message "hello world"
    heroku create
    git push heroku master

### Step 6 - Setup the Facebook App

1. Create or configure a new Facebook App or Page here https://developers.facebook.com/apps/

2. In the app go to Messenger tab then click Setup Webhook. Here you will put in the URL of your Heroku server and a token. Make sure to check all the subscription fields. 

3. Get your Page Access Token and save this. 

4. Go back to Terminal and type in this command to trigger the Facebook app to send messages. Remember to use the token you requested earlier.

    ```bash
    curl -X POST "https://graph.facebook.com/v2.6/me/subscribed_apps?access_token=<PAGE_ACCESS_TOKEN>"
    ```

### Step 7 - Setup the bot

In order for Facebook and Heroku to know each other, we need to make some adjustments to our bot.

1. We have to add an API endpoint to index.js for processing messages and include our token, which we got earlier. 

    ```javascript
    app.post('/webhook/', function (req, res) {
	    let messaging_events = req.body.entry[0].messaging
	    for (let i = 0; i < messaging_events.length; i++) {
		    let event = req.body.entry[0].messaging[i]
		    let sender = event.sender.id
		    if (event.message && event.message.text) {
			    let text = event.message.text
			    sendTextMessage(sender, "Text received, echo: " + text.substring(0, 200))
		    }
	    }
	    res.sendStatus(200)
    })

    const token = "<PAGE_ACCESS_TOKEN>"
    ```
    
    **Attention!!**: Please keep your app secrets out of the version control! I have already seen several projects on Github that shared private_keys, app_secrets etc. publicly.
    
2. Add a function to echo back messages

    ```javascript
    function sendTextMessage(sender, text) {
	    let messageData = { text:text }
	    request({
		    url: 'https://graph.facebook.com/v2.6/me/messages',
		    qs: {access_token:token},
		    method: 'POST',
    		json: {
			    recipient: {id:sender},
    			message: messageData,
    		}
    	}, function(error, response, body) {
    		if (error) {
			    console.log('Error sending messages: ', error)
    		} else if (response.body.error) {
			    console.log('Error: ', response.body.error)
		    }
	    })
    }
    ```

3. Commit the code again and push to Heroku

    ```
    git add .
    git commit -m 'updated the bot to speak'
    git push heroku master
    ```
    
4. Go to the Facebook Page and click on Message to start chatting!


## Optional: How to share my Bot? 📡
To share your Facebook Bot with others you have 2 options:
### *Add a chat Button*

Go [here](https://developers.facebook.com/docs/messenger-platform/plugin-reference) to learn how to add a chat button your page.

### *Create a shortlink*

You can use https://m.me/<PAGE_USERNAME> to have someone start a chat.

## My Messenger Bot "Your Search"

Searchify is a Facebook Messenger bot that sends your search terms 1:1 to Google and returns the top search results back to you. You can contact him directly via Facebook [https://m.me/google.search.bot](https://m.me/google.search.bot/)

The code is open source and anyone can use it as the basis for a new bot. I have removed all KEYs and TOKEN.

This Messenger Bot is hosted on Heroku -> [https://search1fy.herokuapp.com](https://search1fy.herokuapp.com)



