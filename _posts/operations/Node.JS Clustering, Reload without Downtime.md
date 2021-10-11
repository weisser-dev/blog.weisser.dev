Anyone who works with node. js knows how simple it is to build small web applications. But the fact that even complex pages are possible shows us e. g. Airbnb. But that's not what this article is about.
I'd rather tell you how to go on - after writing your web application.
I had already had the case that my server provider restarted the servers overnight and therefore one of my pages was not accessible. Then I researched what I can do and so I tried dirty hacks with shell scripts to start my Node.js app and put it as a service on Linux. 
 But the answer to my problem was much easier.... It's called PM2!
 ### What is PM2?
 PM2 is an advanced, production process manager for Node.js
 Here is an overview of the advantages it offers you:
- Behavior configuration
- Source map support
- Container Integration
- Watch & Reload
- Log management
- Monitoring
- Module System
- Max memory reload
- Cluster Mode
- Hot reload
- Development workflow
- Startup Scripts
- Deployment workflow
- PaaS Compatible
- Keymetrics monitoring
- API

I first thought about the functions I use most to describe in more detail. But in my opinion, the documentary is so detailed that I couldn't do it better. Therefore, here is the documentation of all functions:
[http://pm2.keymetrics.io/docs/usage/quick-start/](http://pm2.keymetrics.io/docs/usage/quick-start/)

If you still have any questions, please feel free to comment on this article. I will do my best to answer them!
