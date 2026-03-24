# AGENTS.md — Rules for AI Agents Working on This Repository

This file contains hard rules for any AI agent (OpenCode, Codex, Claude, GPT, etc.) that reads, edits, or generates content in this repository.

---

## NEVER include real credentials, tokens, or secrets

This is an absolute rule. No exceptions.

**What counts as a secret:**

- API tokens (Telegram, Discord, GitHub, OpenAI, AWS, Azure, ...)
- Passwords, passphrases, or UUIDs used as credentials
- Private keys, certificates, or secrets of any kind
- Internal URLs or endpoints that include auth parameters
- Session tokens, cookies, or bearer tokens
- Database connection strings with credentials

**What to do instead:**

If you need to show an example of what a credential looks like, use a clearly fake placeholder:

```
# Good — obviously fake
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz_example
OPENCODE_SERVER_PASSWORD=<generated-uuid>
API_KEY=sk-...your-key-here...

# Bad — real-looking or actual value
OPENCODE_SERVER_PASSWORD=fd691649-311e-4418-98fa-6a0e21a2659b
```

---

## Why this matters

Once a real credential appears in a public Git repository:

1. It is immediately picked up by secret-scanning bots (GitHub, GitGuardian, truffleHog, ...)
2. It is cached by GitHub's internal systems and may persist even after deletion
3. Force-pushing to remove history does not guarantee it's gone — forks, clones, and caches may still have it
4. The only safe remediation is to **revoke and rotate** the credential

The damage from a leaked bot token or API key can range from unauthorized API usage and cost to full account compromise.

---

## Before writing any content

1. If you are quoting terminal output, env variables, or config files — **scrub all values** before writing
2. If you are writing a debugging article that involves credentials being discovered — **use placeholders**
3. If you are unsure whether something is a secret — **treat it as one**

---

## If you accidentally included a secret

1. Do not try to quietly fix it in a follow-up commit — the history already contains it
2. Immediately inform the user
3. Recommend revoking/rotating the credential
4. Help reset the Git history (orphan branch + force push)

See the post [Accidentally Committed Credentials to a Public Repo?](_posts/operations/2026-03-24-leaked-credentials.md) for the full remediation playbook.
