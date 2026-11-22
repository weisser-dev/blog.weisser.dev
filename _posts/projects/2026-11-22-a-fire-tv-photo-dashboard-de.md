---
title: "Ein smartes Fotodashboard aus altem Fire TV und Monitor"
date: 2026-11-22
lang: de
ref: a-fire-tv-photo-dashboard
categories: [projects]
tags: [fire-tv, android, fotos, dashboard, datenschutz, deutsch]
read_time: true
---

Ich wollte einen alten Fire TV und einen ungenutzten PC-Monitor in einen digitalen Bilderrahmen im Hochformat verwandeln: Familienfotos auf dem Bildschirm, darüber Uhrzeit und Wetter, dazu nützliche Informationen für den Haushalt. Der Monitor hatte schon einen Platz an der Wand. Die Herausforderung war, aus älterer Streaming-Hardware ein passendes Dashboard zu machen, ohne dafür ein neues Display oder ein weiteres Cloud-Konto anzuschaffen.

Das Ergebnis heißt **Stillframe** und ist eine Android-App für Fire TV und Android TV. Den Quellcode, APK-Downloads und eine interaktive Webdemo gibt es im [Repository fire-tv-diashow](https://github.com/weisser-dev/fire-tv-diashow) und auf der [Projektseite](https://weisser-dev.github.io/fire-tv-diashow/).

![Konzept-Mockup: Ein hochkant montierter Monitor zeigt Stillframe und ist mit einem vorhandenen Fire TV sowie einem Handy im lokalen WLAN verbunden.]({{ '/assets/img/projects/fire-tv-dashboard/fire-tv-dashboard-mock.svg' | relative_url }})

*Konzept-Mockup des Aufbaus. Die Bildschirmoberfläche orientiert sich an der App; die gezeichnete Hardware ist kein Foto.*

## Das Dashboard

Im Kern ist Stillframe eine Diashow für lokale Ordner und Alben. Fotos lassen sich am Fernseher auswählen oder per QR-Code vom Handy senden. Die Handyseite wird vom Fernseher im selben lokalen Netzwerk bereitgestellt; die Bilder gehen direkt auf das Gerät. Dort kann ich auch Notizen, Checklisten und die Kalenderanzeige verwalten, statt mit der Fernbedienung zu tippen.

Über den Fotos kann die App Uhrzeit, Datum und optional das Wetter zeigen. Ein abonnierter Kalenderfeed ergänzt anstehende Termine; wiederkehrende Serien lassen sich auf der Handyseite ausblenden. Kalendereinträge mit einem Titel, der mit „TODO:“, „ToDo:“ oder „To do:“ beginnt, erscheinen zusätzlich als Aufgabe mit Datum. Notizen und Aufgaben erscheinen neben dem Kalender. Im Schlafbildschirm können Uhr und Haushaltsübersicht sichtbar bleiben, während die Fotos ausgeblendet sind. Ein Wochenplan kann zwischen Diashow- und Schlafzeiten umschalten.

Die Fire-TV-Fernbedienung bleibt die wichtigste Steuerung. Mit dem Steuerkreuz navigiert man durch Einstellungen und Bildverwaltung; die Mitteltaste öffnet Wiedergabesteuerung und Schnellmenü. Außerdem unterstützt die App Hochformat, verschiedene Bildanpassungen, sanftes Schwenken und Zoomen, Shuffle und eine individuelle Bilddauer.

![Echter Fire-TV-Screenshot von Stillframe: Diashow mit Uhrzeit, Datum, Wetter und Wiedergabesteuerung.]({{ '/assets/img/projects/fire-tv-dashboard/firetv-slideshow-controls.png' | relative_url }})

*Aufnahme der laufenden App. Das gezeigte Beispielfoto enthält ein Tier, keine Person.*

![Echter Fire-TV-Screenshot des Schlafbildschirms mit abgedunkelter Uhrzeit, Datum und Wetter.]({{ '/assets/img/projects/fire-tv-dashboard/firetv-sleep-clock.png' | relative_url }})

## Lokal zuerst, mit klaren Netzwerkgrenzen

Fotos, Alben, Notizen und Aufgaben werden auf dem Fernseher gespeichert. Für den Handy-Upload braucht man ein lokales WLAN, aber keine Internetverbindung, kein Konto und kein gehostetes Backend. Die App schickt die Fotobibliothek nicht an einen Entwickler-Server. Google Fotos und Ambient sind in der aktuellen App nicht enthalten; der lokale Ablauf hängt dadurch nicht von den Partner-APIs dieser Dienste ab.

Damit lässt sich der Foto- und Handy-Ablauf in einem vom Internet getrennten Heimnetz verwenden. Es wäre aber nicht korrekt, jede Funktion als vollständig air-gapped zu bezeichnen: Das Wetter kommt von Open-Meteo, der Kalender wird über den eingetragenen Feed aktualisiert und die Updateprüfung fragt GitHub ab. Diese optionalen Dienste brauchen Internet, um neue Daten abzurufen. Für einen getrennten Betrieb kann man sie deaktivieren; lokale Fotos, Notizen und Aufgaben bleiben auf dem Gerät.

## Für ältere Hardware entwickelt

Ein Fire TV hat im Vergleich zu einem modernen Handy wenig Rechenleistung. Fire OS hält außerdem die HDMI-Ausgabe im Querformat, auch wenn der Monitor hochkant montiert ist. Statt Firmware zu ändern oder Root vorauszusetzen, dreht Stillframe die eigene Oberfläche und passt die Fernbedienungsnavigation an die gedrehte Ansicht an. Die Systemausgabe bleibt unter der Kontrolle von Fire OS.

Diese Grenzen prägen auch die Darstellung. Ein Live-Hintergrundunschärfeeffekt kann teuer sein; die Glass-Flächen verwenden deshalb leichte, transparente Ebenen. Das nächste Foto wird vor dem Wechsel dekodiert und unter das aktuelle Bild gelegt. Das aktuelle Foto blendet aus, ohne dass ein schwarzer Zwischenbildschirm aufblitzt. Erst danach beginnt die Bewegung des neuen Bildes. Die getrennten Phasen vermeiden den doppelten Schwenk, der auf der älteren Hardware ruckelig wirkte.

Die App kann nach einem Neustart wieder starten. Der Schlafplan steuert aber nur die App-Anzeige und weckt keinen Fire TV auf, den das Betriebssystem vollständig ausgeschaltet hat. Bei einem Projekt zur Weiternutzung zählen diese Grenzen genauso wie die Funktionen.

## Was ich ausprobieren wollte

Es sollte keine weitere Smart-Home-Plattform werden. Der alte Monitor sollte als Familienanzeige nützlich werden: mit lokalen Fotos und den Alltagsinformationen, wegen derer man ein Dashboard eingeschaltet lässt – Uhrzeit, Wetter, Termine, Notizen und Aufgaben. Diese Inhalte lassen sich am Handy deutlich angenehmer bearbeiten als mit einer TV-Fernbedienung.

Die [interaktive Demo](https://weisser-dev.github.io/fire-tv-diashow/) zeigt die Hochformat-Oberfläche und Fernbedienungssteuerung im Browser. Sie ist ein Web-Mockup und keine Android-App, die im Browser läuft; Datei-Uploads sind dort deaktiviert. Im [Repository](https://github.com/weisser-dev/fire-tv-diashow) stehen der App-Quellcode, die Build-Anleitung und die aktuellen Funktionshinweise.
