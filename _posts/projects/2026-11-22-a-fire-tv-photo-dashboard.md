---
title: "A Smart Photo Dashboard from an Old Fire TV and Monitor"
date: 2026-11-22
lang: en
ref: a-fire-tv-photo-dashboard
categories: [projects]
tags: [fire-tv, android, photos, dashboard, privacy]
read_time: true
---

I wanted to turn an old Fire TV and a spare PC monitor into a portrait photo frame: family pictures on the screen, a clock and weather above them, and useful household information nearby. The monitor already had a place on the wall. The challenge was making old streaming hardware feel like a purpose-built dashboard without adding another cloud account or buying a new display.

The result is **Stillframe**, an Android app for Fire TV and Android TV. The public source, APK downloads and an interactive web demo are available in the [fire-tv-diashow repository](https://github.com/weisser-dev/fire-tv-diashow) and on the [project page](https://weisser-dev.github.io/fire-tv-diashow/).

![Concept mockup: a portrait monitor running Stillframe, connected to an existing Fire TV and a phone over local Wi-Fi.]({{ '/assets/img/projects/fire-tv-dashboard/fire-tv-dashboard-mock.svg' | relative_url }})

*Concept mockup of the finished setup; the screen layout follows the app, while the surrounding hardware illustration is not a photograph.*

## The dashboard

At its simplest, Stillframe is a slideshow for local folders and albums. Photos can be selected on the TV or sent from a phone by scanning a QR code. The phone page is served by the TV on the same local network, so uploads go directly to the device. It also lets me manage notes, checklists and calendar visibility without typing with the remote.

The display can show the time, date and optional weather over the photos. A subscribed calendar feed adds upcoming events; recurring series can be hidden from the phone page. Calendar entries whose title starts with “TODO:”, “ToDo:” or “To do:” also appear as dated tasks. Notes and to-dos sit alongside the calendar, and the sleep screen can keep the clock and household dashboard visible while the pictures are off. A weekly schedule can switch between slideshow and sleep hours.

The Fire TV remote remains the main control. The directional pad moves through settings and image management, while the centre button opens playback controls and the quick menu. The app also supports portrait presentation, image fitting, gentle pan-and-zoom, shuffle, and per-photo timing.

![Real Fire TV screenshot of Stillframe playing a photo with clock, date, weather and remote controls.]({{ '/assets/img/projects/fire-tv-dashboard/firetv-slideshow-controls.png' | relative_url }})

*A capture from the running app. The displayed sample photo contains an animal, not a person.*

![Real Fire TV screenshot of the sleep screen with a dim clock, date and weather.]({{ '/assets/img/projects/fire-tv-dashboard/firetv-sleep-clock.png' | relative_url }})

## Local first, with clear network boundaries

Photos, albums, notes and tasks are stored on the TV. Uploading from a phone needs a local Wi-Fi network, but it does not need an internet connection, account or hosted backend. The app does not send the photo library to a developer server. Google Photos and Ambient integration are not part of the current app; the local workflow avoids depending on their partner APIs.

That makes the core photo-and-phone workflow usable on an isolated home network. It is not accurate to call every feature fully air-gapped: weather comes from Open-Meteo, calendar refresh reads the configured feed, and update checks contact GitHub. Those optional services need internet access to refresh. Disable them for a disconnected setup; locally stored photos, notes and tasks stay on the device.

## Designing for old hardware

The Fire TV is resource-constrained compared with a modern phone. Fire OS also keeps the HDMI output in landscape, even when the physical monitor is mounted vertically. Instead of modifying firmware or requiring root, Stillframe rotates its own interface and maps remote navigation to the rotated layout. The system output remains under Fire OS control.

The same constraints shape the visuals. A live background blur can be expensive, so the glass-style panels use lightweight translucent layers. The next photo is decoded ahead of a slide change and placed beneath the current photo. The current image fades away without a black frame; only after that does movement begin on the new image. Keeping this separate from the photo motion avoids the restart-and-double-motion effect that made earlier transitions look jerky on the old hardware.

The app can keep running after a reboot, but its sleep schedule controls the app display rather than waking a Fire TV that the operating system has fully powered down. It is a reuse project, so those boundaries matter as much as the feature list.

## What I wanted to prove

This did not need to be another smart-home platform. I wanted the old monitor to become a useful family display, with local photos first and the everyday details that make a dashboard worth leaving on: the time, weather, events, notes and tasks. A phone is a much easier place to edit those details than a TV remote.

The [interactive demo](https://weisser-dev.github.io/fire-tv-diashow/) shows the portrait TV interface and remote controls in a browser. It is a web mockup rather than the Android app running in a browser, and it does not upload files. The [repository](https://github.com/weisser-dev/fire-tv-diashow) contains the app, build instructions and current feature notes.
