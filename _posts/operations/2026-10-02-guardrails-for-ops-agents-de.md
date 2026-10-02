---
title: "Ein KI-Agent betreibt mein Homelab – und warum das nichts Besonderes ist"
date: 2026-10-02
lang: de
categories:
  - operations
  - ai
tags:
  - claude-code
  - agents
  - homelab
  - devops
  - security
  - deutsch
read_time: true
---

*[English version](/blog/2026/10/02/guardrails-for-ops-agents/)*

Mein Homelab hat jetzt Agenten. Einer liest Logs und erklärt, was schiefgelaufen ist. Einer läuft alle 15 Minuten, prüft, ob alles gesund ist – und versucht, Probleme zu beheben. Einer schaut sich die Ergebnisse von CVE-Scans an und aktualisiert verwundbare Abhängigkeiten in meinen eigenen Projekten. Alle sind [Claude Code](https://claude.com/claude-code) im Headless-Modus (`claude -p`), gestartet aus meinem selbstgebauten Dashboard.

Die naheliegende Frage: Ist es nicht verrückt, ein LLM auf einen Server loszulassen? Meine Antwort: Wäre es – wenn man ihm eine Root-Shell gibt und weggeht. Aber so betreibt man *keine* Automatisierung, und so betreibe ich auch diese nicht.

## Der Aufbau in einem Absatz

Ein kleiner Dienst (`agentd`, rund 300 Zeilen Node, keine Abhängigkeiten) läuft neben dem Docker-Host. Mein Dashboard spricht ihn per HTTP mit einem Bearer-Token an; das Dashboard selbst liegt hinter einem Login. `agentd` startet Agenten-Läufe, verwaltet Zeitpläne und speichert jeden Lauf auf der Platte. Jeder Agent ist in einer kleinen JSON-Datei beschrieben: Name, Standardauftrag, ob er nur lesen darf, und ein gemeinsames Regelwerk. Das ist die ganze Architektur.

## Ebene 1: Eine enge, aufgeschriebene Aufgabe

Jeder Agent hat genau eine Aufgabe. Der Log-Agent bekommt: *Hol die Logs dieses Containers, gruppiere die Fehler nach Ursache, bewerte sie, schlage Fixes vor – ändere nichts.* Der Reparatur-Agent bekommt: *Prüfe Container, aktuelle Fehler, Speicherplatz und öffentliche Endpunkte; wenn alles passt, sag das in drei Zeilen, sonst finde die Ursache und behebe sie.*

Dazu bekommt jeder Lauf denselben angehängten System-Prompt mit den Hausregeln:

- Änderungen an Apps, Compose-Dateien, Proxy-Konfiguration oder Workflows **nur über Git**: klonen, ändern, committen, pushen – der CI-Runner deployt. Nie direkt auf dem Server editieren.
- Ohne Git erlaubt: Logs und Status lesen, einen einzelnen Container neu starten.
- Verboten: Daten löschen, Force-Push, Secrets ausgeben, öffentliche Erreichbarkeit ändern, Hosts neu starten, Pakete installieren.
- Wenn ein Fix riskant oder unklar ist: nichts ändern, berichten.
- Jeder Lauf endet mit denselben drei Abschnitten: *Befund*, *Maßnahmen* (mit Commit-Links), *Offen*.

Weil der Agent in einem Arbeitsverzeichnis unterhalb meines Home-Ordners läuft, lädt er außerdem automatisch dieselbe `AGENTS.md`, die ich für jeden anderen Assistenten pflege. Er weiß, wie die Infrastruktur aufgebaut ist, wo was liegt und *wie hier Änderungen gemacht werden* – dasselbe Onboarding, das auch eine neue Kollegin bekäme.

Ein Prompt ist aber keine Sicherheitsgrenze. Er ist die Stellenbeschreibung. Deshalb gibt es weitere Ebenen.

## Ebene 2: Jede Aktion wird vor der Ausführung geprüft

Die Agenten laufen im **Auto-Berechtigungsmodus** von Claude Code. Dabei schaut sich ein separater Sicherheits-Classifier jede Aktion an, *bevor* sie ausgeführt wird, und blockiert alles, was destruktiv, unumkehrbar oder außerhalb des Auftrags ist. Das habe ich nicht einfach geglaubt: Beim Aufbau dieses Setups wollte meine eigene interaktive Session einen Dienst per API-Aufruf von privat auf öffentlich schalten – und wurde gestoppt, weil das Ändern der öffentlichen Erreichbarkeit genau die Art Entscheidung ist, die bei einem Menschen bleiben sollte. Genau dieses Verhalten will ich auch bei einem unbeaufsichtigten Agenten.

## Ebene 3: Eine harte Sperrliste

Der Classifier ist schlau; eine Sperrliste ist dumm und damit berechenbar. Jeder Lauf startet mit `--disallowedTools` für Befehle, die nie nötig sein sollten: `rm -rf`, Docker-Volumes löschen oder prunen, `git push --force`, Reboot und Shutdown, Container auf Hypervisor-Ebene zerstören oder stoppen, `mkfs`, `dd`, Paketmanager. Agenten, die nur lesen dürfen, verlieren zusätzlich das Bearbeiten von Dateien, Committen und Pushen. Der Log-Agent kann alles ansehen und nichts anfassen.

## Ebene 4: Git ist der einzige Weg hinein

Das ist die wichtigste Ebene, und sie hat mit KI gar nichts zu tun. Meine Regel für *mich selbst* lautet: Auf dem Server wird nichts von Hand geändert – jede Änderung ist ein Commit, und ein selbst gehosteter Runner deployt sie. Die Agenten folgen derselben Regel.

Damit bekomme ich alles, was ich mir von einem Änderungsprozess wünsche, gratis:

- **Eine Nachvollziehbarkeit**: Jede Änderung ist ein Commit mit einem Trailer, der sie als Agenten-Änderung kennzeichnet.
- **Einen Diff**, den ich hinterher lesen kann.
- **Ein Rollback mit einem Befehl**: `git revert`, pushen, fertig.
- **Denselben Deploy-Weg** wie für menschliche Änderungen – es gibt keinen „Nur-für-Agenten“-Weg in die Produktion.

## Ebene 5: Begrenzter Schadensradius

Höchstens zwei Agenten laufen gleichzeitig, ein geplanter Agent überlappt nie mit sich selbst, und jeder Lauf lässt sich aus dem Dashboard abbrechen. Secrets werden dem Modell nie als Text übergeben. Wenn der CVE-Scanner GitHub-Zugriff braucht, um private Repositories zu prüfen, wird der Token nur für die Dauer dieses einen Scans in eine temporäre Datei geschrieben und danach gelöscht.

## Die zusätzliche Überwachung: das Dashboard selbst

Agenten berichten, was sie getan haben. Darauf allein verlasse ich mich nicht.

- **Jeder Lauf wird vollständig aufgezeichnet.** `agentd` speichert den kompletten Ereignisstrom: jeden Tool-Aufruf, jeden Befehl, jede Ausgabe. Das Dashboard zeigt das live, während der Agent arbeitet, und danach als lesbaren Verlauf. Wenn ein Agent behauptet „Container neu gestartet“, sehe ich den exakten Befehl.
- **Das Dashboard ist unabhängig von den Agenten.** Container-Zustand, Neustarts, Abstürze der letzten 24 Stunden, Speicherplatz, CVE-Zahlen und Erreichbarkeit kommen direkt aus Docker und den Scannern, nicht aus der Zusammenfassung des Agenten. Meldet der Reparatur-Agent „alles gut“, während ein Container in einer Neustart-Schleife hängt, zeigt das Dashboard den Widerspruch.
- **GitHub ist die zweite Aufzeichnung.** Alles, was ein Agent geändert hat, ist ein Commit in einem Repository – sichtbar in der normalen Historie, auf einem anderen System als dem, auf dem der Agent arbeitet.

## Warum das nichts Besonderes ist

Nimm das Etikett „KI“ weg und schau, was tatsächlich da ist:

- Ein **Bot-Account mit enger Aufgabe** – wie Dependabot oder Renovate.
- Ein **Runbook**, dem er folgt – wie jede Bereitschafts-Automatisierung.
- **Minimale Rechte** – eine Nur-Lesen-Rolle für Analysen, eine eingeschränkte Rolle für Fixes.
- **Änderungen über Versionskontrolle und CI** – wie jede Deployment-Pipeline der letzten zehn Jahre.
- **Audit-Logs, ein Not-Aus und ein begrenzter Schadensradius** – wie bei jedem Cronjob, den man an Produktion heranlässt.

Keine dieser Ideen ist neu. Wir lassen seit Jahren Skripte, CI-Pipelines und Bots auf Produktionssystemen arbeiten, und das Vorgehen, das sicher zu machen, ist bekannt. Ein Agent ist ein fähigeres Skript, das sich zusätzlich selbst erklärt. Er verdient dieselbe Behandlung wie jede andere Automatisierung: klarer Auftrag, begrenzte Rechte, jede Änderung nachvollziehbar und umkehrbar. Kein blindes Vertrauen, keine Panik.

## Was (noch) nicht perfekt ist

Ehrlich zum aktuellen Stand:

- Die Agenten laufen auf dem Hypervisor-Host, weil Claude Code dort angemeldet ist, und erben die Rechte dieses Benutzers. Die Ebenen oben begrenzen, was sie *tun*; eine Sandbox sind sie nicht. Nächster Schritt: ein eigener Systembenutzer mit einer expliziten Liste erlaubter Befehle.
- Bei allem, was nicht trivial ist, sollten die Agenten auf einen Branch pushen und einen Pull Request öffnen, statt direkt auf `main` zu pushen. Kleine, mechanische Fixes (ein Dependency-Update mit grünem Build) dürfen direkt landen. Ein Refactoring nicht.
- Es gibt noch kein hartes Zeit- oder Schrittlimit pro Lauf. Ein hängender Lauf muss von Hand abgebrochen werden.

Nichts davon blockiert ein Homelab. Es sind dieselben Backlog-Punkte, die man für jede neue Automatisierung aufschreiben würde – und genau darum geht es.
