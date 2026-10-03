---
title: "Warum SemVer und Conventional Commits beim AI-Assisted Coding noch wichtiger sind"
date: 2026-08-19
lang: de
ref: semver-and-conventional-commits-with-ai
categories:
  - development
  - ai
tags:
  - semver
  - conventional-commits
  - git
  - agents
  - engineering
  - releases
  - deutsch
read_time: true
---

Wenn Agenten Code schreiben, steigt die Zahl der Commits. Und zwar nicht ein bisschen: Ein Agent, der eine Aufgabe in kleinen Schritten abarbeitet, erzeugt ein Dutzend Commits, in der Zeit, in der ich einen Kaffee koche. Das ist gut für den Durchsatz und schlecht für alle, die das Ergebnis später lesen müssen – mich, meine Reviewer und jedes Werkzeug, das aus der Historie schlau werden will.

Ich lasse inzwischen viel Code von Agenten schreiben, und zwei alte, unspektakuläre Konventionen haben sich als meine nützlichsten Leitplanken erwiesen: [Semantic Versioning](https://semver.org) und [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). Dieser Beitrag erklärt, warum sie mit Agenten wichtiger sind als ohne, und wie ich sie einrichte.

## Das Problem: schnelle Commits, unlesbare Historie

Sich selbst überlassen, erzeugt ein Agent (und ehrlich gesagt auch ein müder Mensch) eine Historie wie diese:

```
update
fix stuff
wip
more changes
fix tests
final
```

Jede dieser Nachrichten stimmt irgendwie und ist trotzdem nutzlos. Das tut an vier Stellen weh:

- **Review.** Ein Reviewer öffnet einen Pull Request mit 25 Commits. Ohne Konvention sieht er nicht, welcher Commit ein Feature, welcher ein Refactoring und welcher ein glücklicher Bugfix ist. Er liest alles oder überfliegt es – beides schlecht.
- **Bisect.** `git bisect` hilft nur, wenn Commits klein sind und jeder genau eine Sache tut.
- **Releases.** „Was hat sich seit der letzten Version geändert?“ wird zum Rätselraten. Release Notes entstehen aus dem Gedächtnis oder gar nicht.
- **Rollbacks.** Mischt ein Commit ein Feature, eine Umbenennung und ein Dependency-Update, lässt sich nichts davon einzeln zurückdrehen.

Neu ist daran nichts, neu ist die Rate. Ein Mensch macht ein paar Commits pro Tag, ein Agent Dutzende, und niemand liest alle sorgfältig. Die Historie muss deshalb *durch ihre Struktur* lesbar sein, nicht nur durch Fleiß.

## Conventional Commits: Schnittstelle zwischen Mensch, Agent und Tooling

Conventional Commits ist ein kleines Format für die Commit-Nachricht:

```
<type>[optionaler scope][!]: <beschreibung>

[optionaler body]

[optionale footer]
```

Ein paar Beispiele:

```
feat(auth): add refresh token rotation
fix(parser): handle empty input without throwing
docs: explain the retry policy in the README
refactor(api)!: rename /v1/items to /v1/products

BREAKING CHANGE: clients must use the new path; the old one returns 410.
```

Gängige Typen sind `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci` und `chore`. Der Scope ist optional und benennt den betroffenen Bereich. Ein `!` hinter Typ oder Scope bzw. ein `BREAKING CHANGE:`-Footer markiert eine inkompatible Änderung.

Warum passt das so gut zu Agenten?

1. **Es ist maschinenlesbar.** Changelogs, Release Notes und Versionssprünge lassen sich aus der Historie erzeugen, statt sie von Hand zu schreiben.
2. **Es lässt sich zuverlässig einhalten.** Agenten befolgen ein klares, enges Format gut, wenn man es ausdrücklich vorgibt. „Schreib eine gute Commit-Nachricht“ ist vage, „nutze Conventional Commits, eine Änderung pro Commit“ ist prüfbar.
3. **Es erzwingt eine Entscheidung.** Um einen Typ zu wählen, muss der Agent (oder Mensch) festlegen, was die Änderung eigentlich ist. Ein Commit, der sich nicht einordnen lässt, macht meist zu viel.
4. **Es gibt Reviewern eine Landkarte.** In einem langen PR zeigen Typ und Scope, wo ich zuerst hinschauen muss: `fix` und `feat` bekommen Aufmerksamkeit, `docs` und `test` einen Überflug.

### Typ und Wirkung auf SemVer

Diese Zuordnung nutze ich:

| Commit-Typ | Beispiel | Versionssprung |
|---|---|---|
| `fix` | `fix(db): close connection on timeout` | PATCH (1.4.2 auf 1.4.3) |
| `feat` | `feat(api): add pagination` | MINOR (1.4.2 auf 1.5.0) |
| beliebiger Typ mit `!` oder `BREAKING CHANGE:` | `refactor(api)!: drop v1 routes` | MAJOR (1.4.2 auf 2.0.0) |
| `perf` | `perf(search): cache index lookups` | meist PATCH |
| `docs`, `test`, `ci`, `build`, `chore`, `refactor` | `docs: fix typo` | standardmäßig kein Release |

Die Spezifikation von Conventional Commits legt selbst nur `fix`, `feat` und die Breaking-Markierung fest; die übrigen Typen sind verbreitete Konvention. Wie `perf` oder `build` die Version beeinflussen, ist eine Teamentscheidung – und ich schreibe sie auf.

## SemVer: ein Vertrag, der Entscheidungen möglich macht

Semantic Versioning sagt: Eine Version ist `MAJOR.MINOR.PATCH`.

- **PATCH:** abwärtskompatible Fehlerbehebungen.
- **MINOR:** abwärtskompatible neue Funktionen.
- **MAJOR:** inkompatible Änderungen.

Es geht nicht um die Zahlen, sondern um das *Versprechen*. Eine Versionsnummer ist eine Aussage über Risiko: „Darauf kannst du ohne Bruch aktualisieren“ oder „lies erst die Hinweise“.

### Warum das mit Agenten wichtiger wird

Ich betreibe Agenten, die Schwachstellen-Scans auswerten und Abhängigkeiten aktualisieren. Die Regel, die ich ihnen gegeben habe, ist simpel: Minor- und Patch-Updates dürfen direkt eingespielt werden, wenn Build und Tests grün sind; Major-Updates nur als Pull Request zur menschlichen Prüfung.

Diese Regel ist überhaupt nur durch SemVer *entscheidbar*. Ohne gemeinsame Bedeutung von „Major“ hat ein Agent keine fundierte Möglichkeit, ein sicheres von einem riskanten Update zu unterscheiden. Mit SemVer ist die Prüfung mechanisch: Version vorher und nachher vergleichen und schauen, welche Stelle sich geändert hat.

Drei weitere Gründe, warum sich SemVer im Agenten-Workflow auszahlt:

- **Rollbacks sind billig.** Ein Tag wie `v1.5.0` ist ein benannter, bekannter guter Stand. Geht eine Agenten-Änderung schief, ist „zurück auf `v1.4.3`“ eine eindeutige Anweisung für Mensch, Deploy-Pipeline oder anderen Agenten.
- **Breaking Changes werden kommuniziert.** Agenten refaktorieren selbstbewusst und ändern dabei manchmal eine öffentliche Schnittstelle, ohne zu merken, dass sie öffentlich ist. Eine Konvention „breaking heißt `!` plus Footer“ macht daraus etwas, das ein Hook oder Reviewer prüfen kann.
- **Konsumenten können Updates vertrauen.** Wer eine Bibliothek, eine API oder auch nur ein CLI veröffentlicht, dessen Nutzer (und deren Agenten) entscheiden automatisch über Updates. Die Versionsnummer ist die Eingabe für diese Entscheidung.

## Ein praktisches Setup

So sieht es bei mir konkret aus. Nichts davon ist aufwendig.

### 1. Eine Regel in der AGENTS.md

Agenten lesen ihre Anweisungen zu Beginn einer Aufgabe – das ist der erste und billigste Hebel:

```markdown
## Commits
- Conventional Commits verwenden: `<type>(<scope>): <beschreibung>`.
- Erlaubte Typen: feat, fix, docs, refactor, perf, test, build, ci, chore.
- Ein Commit = eine Änderung. Kein Feature, Refactoring und
  Dependency-Update in einem Commit mischen.
- Inkompatible Änderungen mit `!` und `BREAKING CHANGE:`-Footer markieren.
- Beschreibung im Imperativ, klein geschrieben, kein Punkt am Ende,
  maximal 72 Zeichen.
- Nie force-pushen. Veröffentlichte Historie nie umschreiben.
- Mit der konfigurierten Git-Identität committen. Keine Werbe- oder
  Attributionszeilen in Commit-Nachrichten.
```

### 2. Ein commit-msg-Hook

Eine Anweisung ist eine Bitte, ein Hook ist eine Prüfung. Das ist ein minimaler `.git/hooks/commit-msg` (oder das Äquivalent in deinem Hook-Manager):

```bash
#!/usr/bin/env bash
msg_file="$1"
first_line="$(head -n1 "$msg_file")"

pattern='^(feat|fix|docs|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._-]+\))?!?: .{1,72}$'

# Von git erzeugte Merge- und Revert-Commits durchlassen.
case "$first_line" in Merge\ *|Revert\ *) exit 0 ;; esac

if ! [[ "$first_line" =~ $pattern ]]; then
  echo "Commit message does not follow Conventional Commits:" >&2
  echo "  $first_line" >&2
  echo "Expected: <type>(<scope>)!: <description>" >&2
  exit 1
fi
```

Ein Agent, der auf diesen Hook trifft, sieht den Fehler, korrigiert die Nachricht und versucht es erneut. Genau diese Rückkopplung sorgt dafür, dass das Format hält.

### 3. Eine Prüfung des PR-Titels

Wer per Squash-Merge zusammenführt, bei dem *wird* der PR-Titel zur Commit-Nachricht auf dem Hauptbranch. Prüfe ihn in der CI mit demselben Muster:

```yaml
name: pr-title
on:
  pull_request:
    types: [opened, edited, synchronize]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - name: Validate PR title
        env:
          TITLE: ${{ github.event.pull_request.title }}
        run: |
          pattern='^(feat|fix|docs|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._-]+\))?!?: .{1,72}$'
          [[ "$TITLE" =~ $pattern ]] || { echo "Bad PR title: $TITLE"; exit 1; }
```

Der Titel läuft über eine Umgebungsvariable statt direkt ins Skript eingesetzt zu werden. Ein PR-Titel ist nicht vertrauenswürdige Eingabe.

### 4. Release-Tags und Changelog

Releases als `vX.Y.Z` taggen. Dann kann ein Release-Tool (es gibt mehrere; nimm eins, das zu deinem Stack passt) aus den Commits seit dem letzten Tag die nächste Version berechnen und den Changelog erzeugen. Selbst ohne Tool lässt sich die Historie jetzt filtern:

```bash
# alles Nutzersichtbare seit dem letzten Release
git log "$(git describe --tags --abbrev=0)"..HEAD --oneline \
  --grep='^feat' --grep='^fix' --grep='!:'
```

### 5. Die Version sichtbar machen

Die laufende Version sollte einsehbar sein: `--version` bei einem CLI, Footer oder Info-Seite bei einer Web-App, ein `/health`- oder `/version`-Endpunkt bei einem Dienst. Geht etwas kaputt, lautet die erste Frage „welche Version ist das?“ – und ein Agent, der ein Deployment debuggt, braucht dieselbe Antwort.

### 6. Leitplanken kurz halten

Neben den Commit-Regeln stehen in meinen Agenten-Anweisungen ein paar Zeilen zum Verhalten: keine Force-Pushes, keine Historie umschreiben, mit der konfigurierten Identität committen, keine zusätzlichen Attributions- oder Werbezeilen in Nachrichten. Kurz und sachlich schlägt lang und clever.

## Typische Fallstricke

- **Zu große Commits.** Der häufigste Fehler: Ein Agent erledigt die ganze Aufgabe und macht dann einen riesigen Commit. Abhilfe: Er soll nach jedem logischen Schritt committen, und die Regel „ein Commit = eine Änderung“ steht in den Anweisungen.
- **Gemischte Themen.** Ein `feat`, das nebenbei Dateien umbenennt und eine Abhängigkeit anhebt, lässt sich nicht einordnen. Fällt dem Agenten die Typwahl schwer, sollte der Commit geteilt werden.
- **`feat` gegen `fix`.** Agenten etikettieren gern alles als `feat`. Ein einfacher Test: Hat es vorher falsch funktioniert (`fix`) oder kann es jetzt etwas Neues (`feat`)? Falsche Etiketten ergeben falsche Versionssprünge.
- **Squash-Merge-Titel.** Die einzelnen Commits können perfekt sein und trotzdem verschwinden, weil der Squash-Commit den PR-Titel übernimmt. Darum ist die Titelprüfung wichtig.
- **Versionen vor 1.0.** Laut SemVer darf sich bei Major-Version 0 jederzeit alles ändern. Entscheide vorab, was das für dich bedeutet, und lass Tooling oder Agenten Minor-Sprünge bei `0.x` nicht pauschal als sicher behandeln.
- **Monorepos und mehrere Services.** Eine einzige Versionsnummer für alles funktioniert selten. Nutze Scopes für Paket oder Service, versioniere getrennt und achte darauf, dass dein Release-Tool das Layout versteht.
- **Versteckte Breaking Changes.** Agenten markieren eine Änderung selten von selbst als breaking. Hat dein Projekt eine öffentliche Schnittstelle, gehört ein Punkt in die Review-Checkliste: „Ändert das etwas, das ein Konsument beobachten kann?“

## Fazit und Checkliste

Conventional Commits und SemVer sind weder neu noch aufregend. Genau deshalb funktionieren sie: Es sind gemeinsame Konventionen, die Menschen, Agenten und Werkzeuge bereits verstehen. Mit Agenten im Prozess sind sie keine nette Hygiene mehr, sondern die Schnittstelle, die eine schnelle Historie prüfbar, releasefähig und umkehrbar hält.

Checkliste zum Mitnehmen:

- [ ] Conventional-Commits-Regel in der `AGENTS.md`, inklusive „ein Commit = eine Änderung“
- [ ] `commit-msg`-Hook, der nicht konforme Nachrichten ablehnt
- [ ] PR-Titel-Check, wenn per Squash gemergt wird
- [ ] Release-Tags `vX.Y.Z`, Changelog aus den Commits erzeugt
- [ ] Schriftliche Regel: Minor/Patch dürfen automatisch, Major nur per PR
- [ ] Breaking Changes mit `!` und `BREAKING CHANGE:`-Footer markiert
- [ ] Version in der laufenden Software sichtbar
- [ ] Leitplanken: kein Force-Push, richtige Identität, keine zusätzlichen Attributionszeilen
- [ ] Entscheidung für Versionen vor 1.0 und für Monorepos
