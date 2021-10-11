---
title: "Host a Tor Hidden Service (Nginx)"
categories:
  - operations
tags:
  - operations
  - nginx
---
## Create and Publish a new Website on Tor

### Prerequisites
Whether you want to create a new website or host an existing one on the Tor network, you will need the following packages in both cases:

**Tor**: 

``` apt-get install tor -y  ```

**Nginx**:

``` apt-get install nginx -y ``` 

### Step 1 - Create Website
*If you already have an existing page you can skip this step.* 

First of all, we need a simple website. For this we create a directory for the page in /var/www. 

``` mkdir -p /var/www/example_page ```

In this folder we now create our page which is supposed to be accessible via the Tor network.

```nano /var/www/example_page/index.html```
 
Our HTML file now gets a little content so that we can see if we are really on our server.

```html
    <!DOCTYPE html>  
       <html>  
           <body>
               <h1>Congratulations!</h1>
                <p>You have successfully set up your Tor Hidden Service!</p>
            </body>
        </html> 
```     
Very good! Step 1 is now done, next we will configure our Nginx service!

### Step 2 - Setup Nginx
First we need a vhost file for our website.

```nano /etc/nginx/sites-enabled/example_page.vhost ```

We now fill up the file with this configuration:

    server {  
	    // localhost and your port
        listen   127.0.0.1:80; 
        // root directory of your website
        root   /var/www/example_page;
        // index.html of your website
        index  index.html;
    }
***Attention**! If you use the parameter "server_name" in your nginx configuration, you also have to add your \*. onion url here (how to get it you can find out in step 3)*

That is the basic vhost File.
Now we just have to validate our vhost-File and restart Nginx.

```nginx -t  ```
```service nginx reload```

**Optional**:
*If you are using for example a Node. js server, you only have to change the port from 80 to your server's port and it will work in the same way.*

 *You also can say ```deny all``` and just ``` allow 127.0.0.1 ``` then your page is just on the Tor Network available.*

### Step 3 - Configure the Tor Hidden Service
Open the tor configuration file:

```nano /etc/tor/torrc  ```

and create there your Hidden Service:

    HiddenServiceDir /var/lib/tor/example_page/  
    HiddenServicePort 80
now just restart Tor 

```service tor restart ```

and your site is available on the Onion Network.

*To find out the current URL of your page change to the Tor folder of your page*

*```cd /var/lib/tor/example_page/ ```*

*and enter the following command here:*

 *```cat hostname```*
 
 
 ___
Have fun with your site!
 I hope the article could help you. 
