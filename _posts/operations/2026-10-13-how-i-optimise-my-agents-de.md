---
title: "Wie ich meine Agenten optimiere: Logs, Berichte, Veto und kleine Schritte"
date: 2026-10-13
lang: de
ref: how-i-optimise-my-agents
categories:
  - operations
  - ai
tags:
  - agents
  - claude-code
  - automation
  - observability
  - deutsch
read_time: true
---

Einen Agenten einmal etwas tun zu lassen, ist leicht. Zehn geplante Agenten über Monate hinweg nützliche Arbeit machen zu lassen, ohne dass ich sie ständig beaufsichtige, ist eine andere Aufgabe. Das meiste, was dabei funktioniert, ist kein schlauer Prompt, sondern langweiliger Betrieb: Logs, Budgets, Berechtigungen, Reviews.

Dieser Beitrag ist die Checkliste, nach der ich vorgehe. Damit er konkret bleibt, ist alles an einem **erfundenen** Beispiel gezeigt: einer kleinen Rezepte-Tauschseite namens *Pantry Notes*. App, Zahlen und Log-Einträge sind für diesen Beitrag ausgedacht.

## Die acht Gewohnheiten

1. **Ein Run-Log-Format für alle Agenten.** Jeder geplante Lauf hängt eine Zeile in dieselbe Art Datei an. Ohne das ist „Was haben die Agenten letzte Woche getan?" Archäologie.
2. **Ein kurzer Morgenbericht.** Eine Seite, aus den Logs erzeugt, in einer Minute lesbar. Ist er lang, höre ich auf, ihn zu lesen.
3. **Ein Review-Agent, der alle Logs liest.** Seine einzige Aufgabe: mir sagen, was *still und leise aufgehört hat*: Agenten, die nicht liefen, Läufe, die immer gleich enden, Ergebnisse, die sich nicht mehr ändern.
4. **Ein Veto-Fenster vor jeder automatischen Veröffentlichung.** Automatisches Veröffentlichen wartet zum Beispiel 24 Stunden als Entwurf. Ich kann abbrechen; Schweigen heißt: weiter.
5. **Enge Berechtigungen pro Aufgabe.** Der Changelog-Agent darf das Repo lesen und eine Datei schreiben. CI oder Secrets kann er nicht anfassen.
6. **Harte Budgets und Timeouts.** Jeder Lauf hat eine maximale Zahl an Schritten, eine Kostengrenze und ein Zeitlimit. Einen hängenden Agenten stoppt der Runner, nicht ich.
7. **Das richtige Modell pro Aufgabe.** Großes Modell für Entwurf und Review, mittleres für die Umsetzung, kleines für Tests und Zusammenfassungen.
8. **Kleine, geprüfte Schritte und Fehler aufschreiben.** Jeder Lauf macht eine kleine Sache und belegt, dass sie funktioniert. Geht etwas schief, kommt die Lehre in die Anweisungen des Agenten.

## Das durchgehende Beispiel: Pantry Notes

Pantry Notes ist eine ausgedachte Rezepte-Tauschseite mit vier geplanten Agenten:

| Agent | Aufgabe | Modellklasse | Berechtigungen |
|---|---|---|---|
| `deps-bumper` | Patch-/Minor-Abhängigkeiten anheben, PR öffnen | mittel | Repo lesen, Branch schreiben, Tests ausführen |
| `link-checker` | Tote Links in Rezepten finden, Liste ablegen | klein | Repo lesen, HTTP nur lesend |
| `changelog-writer` | Release Notes aus gemergten PRs entwerfen | klein | Git-Historie lesen, `drafts/` schreiben |
| `reviewer` | Alle Logs lesen, berichten, was aufgehört hat | groß | nur Logs lesen |

### 1. Ein Run-Log-Format

Jeder Lauf, egal welcher Agent, endet damit, dass eine JSON-Zeile an `runs/<agent>.jsonl` angehängt wird. Das schreibt der Runner, nicht der Agent; auch ein abgestürzter Agent hinterlässt so eine Spur. Hier zur Lesbarkeit formatiert:

```json
{
  "ts": "2026-10-09T03:12:44Z",
  "agent": "deps-bumper",
  "run_id": "deps-bumper-20261009-0312",
  "model_class": "mid",
  "status": "partial",
  "duration_s": 412,
  "turns": 23,
  "cost_usd": 0.84,
  "budget_usd": 1.50,
  "timeout_s": 900,
  "task": "bump patch and minor dependencies",
  "result": "2 of 3 bumps merged-ready, 1 skipped: tests failed",
  "artifacts": ["pr:example/pantry-notes#212"],
  "verified": true,
  "next_action": "retry skipped bump with pinned lockfile",
  "error": null
}
```

Es kommt nicht auf genau diese Felder an. Wichtig ist, dass **Status, Kosten, Dauer, Ergebnis und die Frage, ob das Ergebnis geprüft wurde**, immer an derselben Stelle stehen, damit ein kleines Skript (oder ein kleiner Agent) alle lesen kann.

### 2. Der Morgenbericht

Ein Zusammenfassungs-Job (kleines Modell, nur lesend) macht aus den Logs der letzten 24 Stunden einen Bericht. Das ist der ganze Bericht, und er soll so kurz bleiben:

```text
Pantry Notes - Agenten - 2026-10-10

4 von 4 geplanten Agenten gelaufen. Kosten gesamt: 2,10 $ (Limit: 6,00 $).

OK       link-checker      38 tote Links, 5 neu seit Dienstag
TEILWEISE deps-bumper      2 Updates bereit (PR #212), 1 uebersprungen:
                           Tests fehlgeschlagen
ENTWURF  changelog-writer  Release Notes fuer v1.8.0 wartend, Veroeffentlichung
                           Sa 09:00, falls kein Veto
OK       reviewer          siehe unten

Heute zu tun: PR #212 ansehen, ueber den v1.8.0-Entwurf entscheiden.
```

Ich lese ihn beim Kaffee. Ist alles OK, dauert es zehn Sekunden.

### 3. Der Review-Agent

Der Morgenbericht beschreibt nur, was *passiert* ist. Was mir Sorgen macht, ist, was *nicht* passiert ist. Deshalb liest ein eigener Review-Agent (großes Modell, nur lesender Zugriff auf die Logs) alle Run-Logs der letzten zwei Wochen und muss eine Frage beantworten: **Was hat still aufgehört oder still aufgehört, nützlich zu sein?** Er liefert immer genau drei Punkte, nach Wichtigkeit sortiert:

```text
1. link-checker: seit 11 Tagen keine Fix-PRs, obwohl jeder Lauf tote
   Links meldet. Die Berichte entstehen, aber niemand handelt danach.
   Vorschlag: pro Lauf ein PR mit hoechstens 5 Korrekturen.

2. changelog-writer: die letzten 3 Entwuerfe sind bis auf die
   Versionsnummer identisch. Entweder ist die Vorlage zu starr oder er
   liest die gemergten PRs nicht mehr. Artefakte der Laeufe 0928,
   0930, 1007 pruefen.

3. deps-bumper: 4 Laeufe in Folge "partial", immer dasselbe
   uebersprungene Paket. Ein bekannter Fehler wird endlos wiederholt,
   etwa 0,30 $ pro Lauf. Vorschlag: als bekanntes Problem in die
   Anweisungen des Agenten schreiben und explizit ueberspringen.
```

Drei Punkte sind Absicht. Eine Liste mit fünfzehn „Beobachtungen" wird ignoriert; drei sortierte werden erledigt. Keiner davon ist ein Absturz. Es sind die stillen Fehler: ein Agent, der weiterläuft und aufhört, eine Rolle zu spielen.

### 4. Das Veto-Fenster

Der `changelog-writer` veröffentlicht nie direkt. Er schreibt `drafts/release-1.8.0.md`, und ein Timer veröffentlicht den Entwurf nach 24 Stunden, außer es liegt daneben eine Datei `VETO`. Der Morgenbericht nennt den wartenden Entwurf, damit das Fenster wirklich gesehen wird. Das kostet einen Tag Verzögerung und nimmt die Angst vor automatischem Veröffentlichen. Alles, was öffentlich wird, Nachrichten verschickt oder Geld ausgibt, bekommt so ein Fenster oder eine menschliche Freigabe.

### 5. Enge Berechtigungen pro Aufgabe

Jeder Agent bekommt eine ausdrückliche Erlaubnisliste genau für seine Aufgabe, nichts wird vererbt. Claude Code unterstützt das über Berechtigungsregeln und -modi ([Dokumentation zu Permissions](https://code.claude.com/docs/en/permissions)). Beim `link-checker` lautet die Liste etwa „Dateien lesen, das Link-Check-Skript ausführen, die Berichtsdatei schreiben", sonst nichts. Braucht ein Agent etwas Neues, füge ich genau das hinzu, bewusst. Der Standard ist *verbieten*.

### 6. Harte Budgets und Timeouts

Drei Grenzen pro Lauf, vom Runner durchgesetzt und nicht nur im Prompt erbeten: maximale Schrittzahl, maximale Kosten und ein Zeitlimit. Die Claude-Code-CLI hat Optionen für die ersten beiden (`--max-turns`, `--max-budget-usd`, siehe [CLI-Referenz](https://code.claude.com/docs/en/cli-reference)); das Zeitlimit setze ich im Scheduler. Im Log oben hat `deps-bumper` 0,84 $ von 1,50 $ verbraucht. Erreicht ein Lauf die Grenze, ist das selbst eine Erkenntnis und erscheint im Morgenbericht.

### 7. Modellwahl pro Aufgabe

Ich nehme nicht für alles dasselbe Modell:

- **Großes Modell:** Entwurfsentscheidungen, der Review-Agent, alles, was andere Arbeit beurteilen muss.
- **Mittleres Modell:** Umsetzung, etwa die Abhängigkeits-Updates.
- **Kleines Modell:** Tests ausführen, Zusammenfassungen, der Morgenbericht.

Das ist billiger und oft auch besser: Das kleine Modell ist für Routine schnell genug, und das teure wird dort eingesetzt, wo Urteilsvermögen zählt. Bei Unsicherheit nehme ich in der ersten Woche die leistungsfähigere Klasse und gehe herunter, sobald die Logs zeigen, dass es nicht nötig ist.

### 8. Kleine Schritte und gelernte Lektionen

Jeder Lauf macht eine kleine Sache und prüft sie, zum Beispiel „ein Paket anheben, Tests laufen lassen, Ergebnis festhalten" statt „alles aktualisieren". Das Feld `verified` im Log sagt, ob der Agent die Prüfung wirklich ausgeführt hat und nicht nur Erfolg behauptet. Eine Behauptung ohne Prüfung gilt im Bericht als `unverified`.

Und wenn etwas schiefgeht, kommt die Lehre in die eigenen Anweisungen des Agenten. Nachdem der `deps-bumper` immer wieder dasselbe kaputte Update versucht hatte, bekam seine Anweisungsdatei zwei neue Zeilen:

```text
Known issue: package "image-resizer" 4.x breaks the upload tests.
Do not bump it. Note it in the log as "skipped: known issue" and move on.
```

Der Fehler passiert einmal, die Anweisungsdatei merkt ihn sich, und der nächste Bericht des Review-Agenten wird kürzer. Die Anweisungen sind ein lebendes Runbook, das wie Code geprüft wird.

## Offene Standards für Agenten-Workflows

Sobald mehrere Agenten laufen, beschreibt man jedes Mal dieselben Dinge: wem ein Workflow gehört, welcher Agent welchen Schritt macht, was er nutzen darf, welches Budget er hat, was protokolliert wird. Inzwischen gibt es offene Standards, um Agenten-Workflows zu beschreiben, zum Beispiel das [Agentic Workflow Protocol (AWP)](https://agenticworkflowprotocol.org). Laut seiner Website ist es eine offene Spezifikation für portable, nachvollziehbare und richtliniengesteuerte Agenten-Workflows, definiert in deklarativen YAML-Manifesten, die Agenten, Werkzeuge, Ablaufreihenfolge, Budgets, Berechtigungen und Audit-Ereignisse abdecken. Es ist als Entwurf (`v1alpha1`) gekennzeichnet, Felder können sich also ändern. Ich nenne es als Beispiel für die Richtung, nicht als Voraussetzung dieses Beitrags; die Gewohnheiten oben funktionieren mit einfachen Dateien und einem Scheduler.

## Womit ich anfangen würde

Wer schon Agenten laufen hat und nichts davon, beginnt mit den zwei billigsten Dingen: **ein Log-Format** und **harte Limits**. Alles andere (Bericht, Review-Agent, Vetos) baut auf verlässlichen Logs auf. Danach kommt der Review-Agent, denn stille Fehler sind die, die am meisten kosten.

## Quellen

- Anthropic: [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
- Claude Code: [Run Claude Code programmatically (headless)](https://code.claude.com/docs/en/headless)
- Claude Code: [Permissions](https://code.claude.com/docs/en/permissions)
- Claude Code: [CLI reference](https://code.claude.com/docs/en/cli-reference) (`--max-turns`, `--max-budget-usd`, `--model`, `--permission-mode`)
- Claude Code: [Manage costs](https://code.claude.com/docs/en/costs)
- JSON Lines: [jsonlines.org](https://jsonlines.org/)
- Agentic Workflow Protocol: [agenticworkflowprotocol.org](https://agenticworkflowprotocol.org)

*Pantry Notes, seine Agenten, Zahlen und Log-Einträge sind zur Veranschaulichung erfunden.*
