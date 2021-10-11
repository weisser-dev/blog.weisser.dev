---
title: "Very simple & fast Node.js Deployment"
categories:
  - operations
tags:
  - operations
  - node.js
  - pm2
---
At the moment I'm in the process of rebuilding everything here. My private laptop, the blog etc..

Since it always annoyed me that I only updated my blog via FTP (i.e. developed JS files with VS code locally and then shared them via ftp) I thought it would be cool if I quickly build a process to save that ftp way.
So I thought about what is the fastest & easiest way to get the decision to build a cronjob that fetches the files from my GitRepo every minute. I also configured PM2 to watch to changes automatically.

## Requirements
- working [Node.JS App](https://whit-e.com/building-nodejs-rest-api)
- installed [PM2](https://whit-e.com/nodejs-server-best-practise) 
- GIT-Repository

## Fast Deployment
First we go to our /var/www/ Folder at our SERVER and Checkout the Service: 
```
git clone https://github.com/whit-e/microservice_blueprint_nodejs
```
Info: *If Git asks you now for your credentials, we still have to configure that this will not happen in the future. 

It would be the **best way** if we put a ssh key on the root server and link it to our git account: https://help.github.com/en/articles/connecting-to-github-with-ssh
The **quickest way** is to execute the command first: `` git config --global credential.helper store``*

Next we go into our project and install all dependencies ``cd yourProject && npm install``

After that, we could start our project with **PM2**:
```pm2 start ./bin/www --watch```
*The ``--watch `` command ensures that our Node.js application is restarted when file changes are made.*
If we now change something at our GitHub Repo and pull it, the changes should be applied automatically.
It works? Fine. Now let's create our CronJob, which pulls every minute.

First we create a new Folder, called **cron** in **/opt/**, after that we switch to this directory and create a simple, executable shell File:
```shell
mkdir /opt/cron
cd /opt/cron
cat > pullAutomatically.sh
chmod +x pullAutomatically.sh
```
Now we tell our pullAutomatically what exactly should happen:
``go to the folder of our application`` -> ``do git pull there``
for that, edit the file and safe the following there: 
```
#!/bin/bash
cd /var/www/yourApplication
git pull
```

Everything what is missing now -> execute this file every minute.
For this we use crontab:
```
crontab -e 
#add there
*/1 * * * * /opt/cron/pullAutomatically.sh
```

Now we  are finished.

