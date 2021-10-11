---
title: "Host your own VCS Server"
categories:
  - Operations
tags:
  - Operations
  - VCS
---
### Why should I host my own Version Control System?

In times of cloud storage, Github, Bitbucket & Co. nobody will worry about hosting their sources.
It goes very quickly, you create a project, commits your sources and there's a Private_Key in Github's public repo.
Unfortunately, very few people know how to delete their history, so this key will be there forever - you think nobody is that stupid? Take a look at [https://github.com/search?
l=JavaScript&q=secretkey%3D&type=Code&utf8=%E2%9C%93](https://github.com/search?%20l=JavaScript&q=secretkey=&type=Code&utf8=%E2%9C%93)

Now you can see how carelessly data is handled today.

Imagine you have a project, an idea that is considering making money because it's so unique, so why put this project in the hands of a stranger hoster? 

That's why I'll show you two options how to host your code on your own server.

### Option A - Gitea
First - why is Gitea Option A?
Now Gitea is a Fork of Gogs, which is much more active than the original project. One of the reasons for this is that Gogs was originally developed by only one person and [Gitea is a community project.](https://blog.gitea.io/2016/12/welcome-to-gitea/)
It is one of the lightest version control systems and would even run on a Raspberry Pi. 

If you are interested in testing it you have the possibility to do so here: [https://try.gitea.io/](https://try.gitea.io/) - I have created an account there which is called "test.whit-e" and has as password "tester". You are welcome to use it, but don't change the password for fairness, please.

#### Installation
Installing Gitea is very easy.
Assuming that you have already installed git, this is not the case you can do this as follows:
```sudo apt-get install git -y```
Next we change to the folder where Gitea should be installed, I created the folder **gitea** in /**opt**.
``` 
mkdir /opt/gitea
cd /opt/gitea 
``` 
There we download the [latest version of Gitea](https://dl.gitea.io/gitea/) with wget and give it the necessary permissions:
```
wget -O gitea https://dl.gitea.io/gitea/1.3.2/gitea-1.3.2-linux-amd64
chmod +x gitea
```
Next we can start Gitea and continue the installation via the browser. There you have to enter the permissions, MySQL data, folders etc. that apply to you.
```./gitea web ```

**Attention**: By default, Gitea runs on port 3000 when you start it and get the following error message:
```[..... io/gitea/cmd/web. go: 156 runWeb ()] [E] Failed to start server: listen tcp 0.0.0.0:3000: bind: address already in use ```

you can easily change the default port.
Just edit the file in ***/opt/gitea/custom/conf/app.ini*** and add the following lines to it: 
```
[server]
HTTP_PORT        = 5000
``` 
If the app. ini file does not exist yet, start Gitea and it will be generated automatically.

### Option B - Gogs
There are several ways to install gogs. The installation is basically the same as with Gitea.
The best thing to do is to visit the site and choose the most suitable one ;)
[https://gogs.io/docs/installation](https://gogs.io/docs/installation)

 - [install from binary](https://gogs.io/docs/installation/install_from_binary)
 - [install from sources](https://gogs.io/docs/installation/install_from_sources)
 - [install from packages](https://gogs.io/docs/installation/install_from_packages)

### Option C - Gitlab
#### Systemrequirements
The published [GitLab hardware requirements](http://docs.gitlab.com/ee/install/requirements.html#hardware-requirements) recommend using a server with:
- 2 cores
- 4GB of RAM

#### Dependencies:
In the beginning we have to install some dependencies to get Gitlab up and running. 
These can easily be pulled and installed from the Ubuntu standard package repository:
```
sudo apt-get update
sudo apt-get install ca-certificates curl openssh-server postfix
``` 
#### Installation
After installing the dependencies, we can now take care of installing Gitlab.

To do this we have to download the [installation script](https://packages.gitlab.com/gitlab/gitlab-ce/install) first. It is recommended to switch to the /tmp folder first.
```
cd /tmp
curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
``` 
Next, we'll run it:
```sudo bash /tmp/script.deb.sh```
 
But what does this script actually do? It makes sure that we can use Gitlab just like other packages via "***apt***" -
 our standard package management - can install. 
 And this is what we're going to do now:
 ```sudo apt-get install gitlab-ce``` 
 After the Gitlab is installed, it would theoretically be available.
But I recommend to take a look at the "/etc/gitlab/gitlab/gitlab. rb" and to register your domain with external_url:
```sudo nano /etc/gitlab/gitlab.rb``` 

Save and close the file. Then run the command to reconfigure Gitlab:
```sudo gitlab-ctl reconfigure``` 

#### Login
Now our Gitlab is available. We can log in with root and the corresponding password! 
It is useful to get an overview of the available functions. These are for example: changing your user name, assigning a new password, creating groups, etc. That's the best way to learn!
________


## Conclusion
I have already had good experiences with all 3 systems, but I am currently using Gitea. Personally, it's just what I like best. As already mentioned, it is written in Go and incredibly lightweight. Even on a raspberry pi, it will run smoothly. 

There are certainly some other good self hosted VCS, but I don't have any experience with them yet, so I don't want to go into them in more detail. But you can find a big listing here: [https://alternativeto.net/software/gitlab/](https://alternativeto.net/software/gitlab/)

If you have already had good experiences with other systems, feel free to write them in the comments, I am always open for new technologies.
