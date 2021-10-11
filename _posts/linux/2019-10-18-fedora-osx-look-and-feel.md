---
title: "HOW TO: Fedora looks & feels like Mac OS X Mojave"
categories:
  - linux
tags:
  - linux
  - fedora
---
## Introduction
In this tutorial I will show you how to get some features and the layout of OS X on your Fedora.

### For the Hater who will say "You want it to look like a Mac, buy one".
I know there are some who will say "if you want it to look like os x, buy a MacBook",  some of my work colleagues reacted in the same way... But, I have 2 MacBooks (1 MacBook Pro mid 2011, 1 MacBook Pro mid 2018). The 2018 is from work and just bad. With the keyboard, the keys regularly lock up and the speakers randomly start noisy. And I don't buy it for 3000€ electronic trash!
I'm completely satisfied with my Mid2011 MacBook, but it's no longer updateable, so I bought a Lenovo for programming on the couch. But for the development Windows is out of question -> that´s why i started using Fedora. And here I would not like to do without some features I am used to as a long time Apple user therefore this tutorial!

## Prerequisites
- Fedora 29 or 30
- Gnome 3
- Small Linux KnowHow

## Design before Functionality
Following Apple's motto - design before functionality (otherwise the new MacBooks wouldn't be so buggy) we start with the look, the appearance.
In order to be able to make different settings on ``Gnome`` we first have to install ``Gnome-Tweaks``
```shell
sudo dnf install gnome-tweaks
```
After we install tweaks, pls restart your System. Or just log out and in.
Next, we need to download our desired OS X themes. Here you can find the icon pack "[OS Catalina]((https://www.gnome-look.org/p/1309810/))" the theme "[Mojave-dark](https://www.gnome-look.org/p/1275087/)" and the shell theme "[mcOS11-Shell.zip](https://www.gnome-look.org/p/1220826/)". 
After downloading the files, we extract the content and move it to /usr/share/themes or icons:
```shell
sudo tar -xvf Mojave-dark.tar.xz --directory /usr/share/themes/
sudo tar -xvf OS_Catalina.tar.xz --directory /usr/share/icons/
sudo unzip mcOS11-Shell.zip && mv mcOS11-Shell /usr/share/themes/
```
Next we download the Apple Typical font "[roboto](https://www.fontsquirrel.com/fonts/roboto)", unzip the content and install the fonts (just double click on the .ttf file):
```shell
sudo unzip roboto.zip
```
Now we have all the files, themes, icons, fonts and so on we need for a nice OS X UI under Gnome3 & Fedora. Next we have to configure Gnome. For this we start Gnome tweaks.
In the next screenshots you can see which things have to be configured:
1. ``Extensions`` > ``User Themes`` > ``enable`` -  for your Shell Theme![](https://whit-e.com/images/screenshots_osx_fedora/extensions_user_themes.jpg)
	2. For Appearance we have to make changes to ``Applications``, ``Icons`` and ``Shell``:![](https://whit-e.com/images/screenshots_osx_fedora/appearance_settings.jpg)
	3. For the correct font we have to set ``Interface Text`` & ``Legacy Window Titles`` to ``Roboto Bold`` and ``Document Text`` to ``Roboto Regular``![](https://whit-e.com/images/screenshots_osx_fedora/fonts.jpg)
	4. As last step we only have the Window Titlebars. Here we activate the titlebar buttons "Maximize" and "Minimize" and set the Placement to "left". ![](https://whit-e.com/images/screenshots_osx_fedora/window_titlebars.jpg)

Now your Fedora should looks like a Mac OS X! 
## Let´s add the ``functionality``
Here is a short overview of what we will add:
- [The dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
- [Gesture control](https://extensions.gnome.org/extension/1253/extended-gestures/) (change the workspace with 3 fingers, for example) 
- [Hide Top Panel](https://extensions.gnome.org/extension/740/hide-top-panel/)
- [Windows in Maximize gets its own workspace](https://extensions.gnome.org/extension/1181/maximize-to-workspace/).
Info: *All these functionalities are installed directly via Gnome Extensions. If you already have a Chrome on your Fedora, I recommend to use this chrome extension [Gnome Shell-Integration](https://chrome.google.com/webstore/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep) to avoid the manual installation and it works much better with this extension, because it analyzes your current Gnome & Fedora version. After the installation of your extensions, i would recommend to restart your operating system.*
 ### Manual Extension Installation
 #### Extended Gestures
 ```shell
 git clone https://github.com/mpiannucci/gnome-shell-extended-gestures
sudo cp -r gnome-shell-extended-gestures/extendedgestures@mpiannucci.github.com /usr/share/gnome-shell/extensions
 ```
#### Maximize to Workspace
```shell
git clone https://github.com/rliang/gnome-shell-extension-maximize-to-workspace ~/.local/share/gnome-shell/extensions/maximize-to-workspace@rliang.github.com
gnome-shell-extension-tool -e maximize-to-workspace@rliang.github.com
```
#### Dash to Dock
```shell
git clone https://github.com/micheleg/dash-to-dock.git
cd dash-to-dock/
make install
```
Now you can configure your gestures and other extensions in tweaks. 
I hope you enjoy your Fedora with the OS X look.

If you are also interested in "How to get the dynamic wallpaper from mojave" check this [https://www.omgubuntu.co.uk/2018/06/macos-mojave-dynamic-background-linux](https://www.omgubuntu.co.uk/2018/06/macos-mojave-dynamic-background-linux)

PS. which currently still annoys me, maximize only creates a new workspace but doesn't open the application in fullscreen (f11 shortcut).
If necessary, I will soon write my own Gnome extension for this. If you are interested in it, please write it in the comments and check my [Github](https://github.com/whit-e) account regularly, maybe it is already there when you read that tutorial ;) 
