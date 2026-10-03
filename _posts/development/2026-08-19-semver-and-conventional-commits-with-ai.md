---
title: "Why SemVer and Conventional Commits Matter Even More with AI-Assisted Coding"
date: 2026-08-19
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
lang: en
ref: semver-and-conventional-commits-with-ai
read_time: true
---

When agents write code, the number of commits goes up. Not by a little: an agent that works through a task in small steps can produce a dozen commits in the time it takes me to make coffee. That is great for throughput and terrible for anyone who has to read the result later, including me, my reviewers, and every tool that tries to make sense of the history.

I let agents write a lot of code these days, and two old, boring conventions have turned out to be the most useful guardrails I have: [Semantic Versioning](https://semver.org) and [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). This post explains why they matter more with agents than without, and how I set them up.

## The problem: fast commits, unreadable history

Left alone, an agent (and honestly, a tired human) produces a history like this:

```
update
fix stuff
wip
more changes
fix tests
final
```

Every one of those messages is technically true and completely useless. Concretely, this hurts in four places:

- **Review.** A reviewer opens a pull request with 25 commits. Without a convention they cannot tell which commit is a feature, which is a refactor and which is a lucky bugfix. They read everything or they skim, and both are bad.
- **Bisecting.** `git bisect` only helps if commits are small and each one does one thing.
- **Releases.** "What changed since the last version?" turns into guesswork. Release notes get written from memory, or not at all.
- **Rollbacks.** If a commit mixes a feature, a rename and a dependency bump, you cannot revert one without the others.

None of this is new. What is new is the rate. A human produces a few commits per day; an agent produces dozens, and nobody reads all of them carefully. The history needs to be readable *by structure*, not just by effort.

## Conventional Commits: an interface between human, agent and tooling

Conventional Commits is a small format for the commit message:

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

A few examples:

```
feat(auth): add refresh token rotation
fix(parser): handle empty input without throwing
docs: explain the retry policy in the README
refactor(api)!: rename /v1/items to /v1/products

BREAKING CHANGE: clients must use the new path; the old one returns 410.
```

The common types are `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci` and `chore`. The scope is optional and names the area that changed. A `!` after the type or scope, or a `BREAKING CHANGE:` footer, marks an incompatible change.

Why is this such a good fit for agents?

1. **It is machine-readable.** Changelogs, release notes and version bumps can be generated from the history instead of written by hand.
2. **It is easy to follow reliably.** Agents are good at following a clear, narrow format when you state it explicitly. "Write a good commit message" is vague; "use Conventional Commits, one change per commit" is checkable.
3. **It forces a decision.** To pick a type, the agent (or human) has to decide what the change actually is. A commit that cannot be classified is usually a commit that does too much.
4. **It gives reviewers a map.** In a long PR, the type and scope tell me where to look first: `fix` and `feat` get attention, `docs` and `test` get a skim.

### Type to SemVer effect

This is the mapping I use:

| Commit type | Example | Version bump |
|---|---|---|
| `fix` | `fix(db): close connection on timeout` | PATCH (1.4.2 to 1.4.3) |
| `feat` | `feat(api): add pagination` | MINOR (1.4.2 to 1.5.0) |
| any type with `!` or `BREAKING CHANGE:` | `refactor(api)!: drop v1 routes` | MAJOR (1.4.2 to 2.0.0) |
| `perf` | `perf(search): cache index lookups` | usually PATCH |
| `docs`, `test`, `ci`, `build`, `chore`, `refactor` | `docs: fix typo` | no release by default |

The Conventional Commits specification itself only fixes `fix`, `feat` and the breaking marker; the others are widely used conventions. How `perf` or `build` affect versions is a team decision, and I write it down.

## SemVer: a contract that makes decisions possible

Semantic Versioning says a version is `MAJOR.MINOR.PATCH`:

- **PATCH:** backwards-compatible bug fixes.
- **MINOR:** backwards-compatible new functionality.
- **MAJOR:** incompatible changes.

The point is not the numbers, it is the *promise*. A version number is a statement about risk: "you can upgrade to this without breaking things" or "read the notes first".

### Why this gets more important with agents

I run agents that look at vulnerability scans and update dependencies. The rule I gave them is simple: minor and patch updates may be applied directly if the build and tests pass; major updates only as a pull request for a human to review.

That rule is only *decidable* because of SemVer. Without a shared meaning of "major", an agent has no principled way to tell a safe update from a risky one. With it, the check is mechanical: compare the version before and after, and look at which component changed.

There are three more reasons SemVer pays off in an agent workflow:

- **Rollbacks are cheap.** A tag like `v1.5.0` is a named, known-good point. If an agent-made change goes wrong, "go back to `v1.4.3`" is an unambiguous instruction for a human, a deploy pipeline or another agent.
- **Breaking changes get communicated.** Agents refactor confidently, and sometimes they change a public interface without noticing it is public. A convention that says "breaking means `!` plus a footer" turns that into something a hook or a reviewer can check.
- **Consumers can trust upgrades.** If you publish a library, an API or even a CLI, other people (and their agents) will decide automatically whether to upgrade. Your version number is the input to that decision.

## A practical setup

Here is what I actually put in place. None of it is fancy.

### 1. A rule in AGENTS.md

Agents read their instructions at the start of a task, so this is the first and cheapest lever:

```markdown
## Commits
- Use Conventional Commits: `<type>(<scope>): <description>`.
- Allowed types: feat, fix, docs, refactor, perf, test, build, ci, chore.
- One commit = one change. Do not mix a feature, a refactor and a
  dependency bump in one commit.
- Mark incompatible changes with `!` and a `BREAKING CHANGE:` footer.
- Imperative, lower-case description, no trailing period, max 72 characters.
- Never force-push. Never rewrite published history.
- Commit under the configured git identity. No promotional or
  attribution lines in commit messages.
```

### 2. A commit-msg hook

Instructions are a request; a hook is a check. This is a minimal `.git/hooks/commit-msg` (or the equivalent in your hook manager):

```bash
#!/usr/bin/env bash
msg_file="$1"
first_line="$(head -n1 "$msg_file")"

pattern='^(feat|fix|docs|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._-]+\))?!?: .{1,72}$'

# Let merge and revert commits generated by git through.
case "$first_line" in Merge\ *|Revert\ *) exit 0 ;; esac

if ! [[ "$first_line" =~ $pattern ]]; then
  echo "Commit message does not follow Conventional Commits:" >&2
  echo "  $first_line" >&2
  echo "Expected: <type>(<scope>)!: <description>" >&2
  exit 1
fi
```

An agent that hits this hook sees the error, fixes the message and tries again. That feedback loop is exactly what makes the format stick.

### 3. A pull request title check

If you squash-merge, the PR title *becomes* the commit message on the main branch. Check it in CI with the same pattern:

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

Note that the title goes through an environment variable instead of being pasted into the script. A PR title is untrusted input.

### 4. Release tags and a changelog

Tag releases as `vX.Y.Z`. Then a release tool (there are several; pick one that fits your stack) can compute the next version from the commits since the last tag and generate the changelog. Even without a tool, the history is now filterable:

```bash
# everything user-visible since the last release
git log "$(git describe --tags --abbrev=0)"..HEAD --oneline \
  --grep='^feat' --grep='^fix' --grep='!:'
```

### 5. Show the version

Make the running version visible: `--version` for a CLI, a footer or an about page for a web app, a `/health` or `/version` endpoint for a service. When something breaks, the first question is "which version is this?", and an agent debugging a deployment needs the same answer.

### 6. Keep the guardrails short

Next to the commit rules, my agent instructions have a few lines on behavior: no force-pushes, no history rewrites, commit under the configured identity, no extra attribution or marketing lines in messages. Short and factual beats long and clever.

## Typical pitfalls

- **Commits that are too big.** The most common failure: an agent finishes a whole task and then makes one giant commit. Fix: tell it to commit after each logical step, and keep the "one commit = one change" rule in the instructions.
- **Mixed topics.** A `feat` that also renames files and bumps a dependency cannot be classified. If the agent struggles to name the type, the commit should be split.
- **`feat` versus `fix`.** Agents tend to label everything `feat`. A simple test: did it behave wrongly before (`fix`), or does it do something new (`feat`)? Wrong labels produce wrong version bumps.
- **Squash-merge titles.** The individual commits may be perfect and still disappear, because the squash commit takes the PR title. That is why the PR title check matters.
- **Pre-1.0 versions.** SemVer says anything may change at any time while the major version is 0. Decide up front what that means for you, and do not let tooling or agents treat `0.x` minor bumps as safe by default.
- **Monorepos and multiple services.** One version number for everything rarely works. Use scopes to name the package or service, version them separately, and make sure your release tool understands the layout.
- **Hiding breaking changes.** Agents rarely mark a change as breaking on their own. If your project has a public interface, add a checklist item to the review: "does this change anything a consumer can observe?"

## Wrap-up and checklist

Conventional Commits and SemVer are not new and not exciting. That is exactly why they work: they are shared conventions that humans, agents and tools already understand. With agents in the loop they stop being nice-to-have hygiene and become the interface that keeps a fast-moving history reviewable, releasable and reversible.

Checklist to take away:

- [ ] Conventional Commits rule in `AGENTS.md`, including "one commit = one change"
- [ ] `commit-msg` hook that rejects non-conforming messages
- [ ] PR title check if you squash-merge
- [ ] Release tags `vX.Y.Z`, changelog generated from commits
- [ ] Written rule: minor/patch updates may be automatic, major only via PR
- [ ] Breaking changes marked with `!` and a `BREAKING CHANGE:` footer
- [ ] Version visible in the running software
- [ ] Guardrails: no force-push, correct identity, no extra attribution lines
- [ ] A decision for pre-1.0 versions and for monorepos
