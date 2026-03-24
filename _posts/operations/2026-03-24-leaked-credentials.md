---
title: "Accidentally Committed Credentials to a Public Repo?"
date: 2026-03-24
categories:
  - operations
  - security
tags:
  - git
  - security
  - credentials
  - secrets
  - incident-response
read_time: true
excerpt: "Step-by-step remediation for leaked API keys, tokens, and passwords in public Git repositories. What to do in the first 60 seconds, how to clean the history, and how to prevent it from happening again."
---

It happens. You paste terminal output into a blog post, commit a `.env` file, or an AI agent includes a real credential in generated content. The secret is now in a public repository. Here is what to do.

## Step 1: Revoke the credential immediately (< 60 seconds)

This is the only step that actually stops the damage. Do it before anything else.

The credential is already compromised the moment it hits a public repo. Automated scanners like [GitGuardian](https://www.gitguardian.com/), [truffleHog](https://github.com/trufflesecurity/trufflehog), and GitHub's own secret scanning pick up new commits within seconds. Assume it has already been seen.

| Credential type | How to revoke |
|---|---|
| Telegram Bot Token | `@BotFather` → `/mybots` → select bot → **API Token** → **Revoke** |
| GitHub Personal Access Token | Settings → Developer settings → Personal access tokens → Delete |
| OpenAI API Key | platform.openai.com → API keys → Delete |
| AWS Access Key | IAM → Users → Security credentials → Deactivate + Delete |
| Discord Bot Token | Developer Portal → Application → Bot → **Reset Token** |
| Generic API key | Check the provider's dashboard — every service has a revoke/rotate option |

After revoking, generate a new credential and store it properly (see [Step 4](#step-4-store-secrets-properly-going-forward)).

---

## Step 2: Remove it from the current content

Fix the file that contains the secret right now. Replace the real value with a placeholder:

```bash
# Before
OPENCODE_SERVER_PASSWORD=fd691649-311e-4418-98fa-6a0e21a2659b

# After
OPENCODE_SERVER_PASSWORD=<generated-uuid>
```

Commit and push the fix:

```bash
git add .
git commit -m "fix: replace leaked credential with placeholder"
git push
```

This does **not** remove it from history — but it removes it from the current state and shows intent.

---

## Step 3: Wipe the Git history

Deleting a commit does not delete history. Anyone who cloned or forked the repo before the fix still has the secret. GitHub also caches commit content internally.

The cleanest option for a personal repo is an orphan reset — this replaces the entire history with a single new initial commit containing only the current (clean) state:

```bash
# 1. Create a new orphan branch (no history)
git checkout --orphan clean-start

# 2. Stage everything in its current clean state
git add -A

# 3. Create a single new initial commit
git commit -m "initial commit"

# 4. Delete the old main branch
git branch -D main

# 5. Rename the orphan to main
git branch -m main

# 6. Force push to overwrite the remote history
git push --force origin main
```

After this, `git log` shows exactly one commit.

**For repositories with collaborators or forks**, the orphan approach is still the fastest path. Inform anyone who has a local clone — they will need to re-clone:

```bash
git clone https://github.com/you/your-repo.git
```

They cannot `git pull` after a force push that rewrites history — a fresh clone is required.

### Alternative: BFG Repo Cleaner

If you want to keep the full history but surgically remove only the secret, [BFG Repo Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) is faster than `git filter-branch`:

```bash
# Install (macOS)
brew install bfg

# Create a file listing the secret strings to remove
echo "fd691649-311e-4418-98fa-6a0e21a2659b" > secrets.txt

# Run BFG against a bare clone
git clone --mirror https://github.com/you/your-repo.git repo-mirror.git
bfg --replace-text secrets.txt repo-mirror.git

# Clean up and force push
cd repo-mirror.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

BFG rewrites every commit that contains the string, replacing it with `***REMOVED***`. History is preserved but the secret is gone.

---

## Step 4: Store secrets properly going forward

The root cause is almost always that a secret ended up somewhere it should not be — a blog post, a committed config file, a debug log. Here is the prevention stack:

### Never commit secrets to Git

Use `.gitignore` from the start:

```
# .gitignore
.env
.env.local
*.config.json
*secret*
*credentials*
```

### Use a local config file pattern

For project configs that contain tokens, keep the real file gitignored and commit only a template:

```
remote-opencode.config.json       # gitignored, contains real token
remote-opencode.config.example.json  # committed, contains placeholders
```

### Use environment variables

```bash
export TELEGRAM_BOT_TOKEN="your-token"
# or in .env (gitignored):
TELEGRAM_BOT_TOKEN=your-token
```

### Use a secret manager for teams

- [1Password Secrets Automation](https://developer.1password.com/docs/cli/)
- [HashiCorp Vault](https://www.vaultproject.io/)
- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) for CI/CD

### Enable GitHub secret scanning

In your repo settings: **Security** → **Secret scanning** → Enable. GitHub will alert you if a known secret pattern appears in a push before it causes damage.

### Add pre-commit hooks

[detect-secrets](https://github.com/Yelp/detect-secrets) or [gitleaks](https://github.com/gitleaks/gitleaks) scan your staged changes before every commit:

```bash
# Install gitleaks (macOS)
brew install gitleaks

# Scan your repo
gitleaks detect --source .

# Add as pre-commit hook
gitleaks protect --staged
```

---

## For AI agents: a note

If you are an AI agent writing documentation, blog posts, or code — **never include real credential values**, even when quoting terminal output or debugging logs. Always replace with placeholders like `<your-token>`, `<generated-uuid>`, or `***`.

See [AGENTS.md](../../AGENTS.md) for the full rules.

---

## Checklist

When you find a leaked credential:

- [ ] Revoke the credential immediately
- [ ] Fix the current file (replace with placeholder)
- [ ] Commit and push the fix
- [ ] Wipe Git history (orphan reset or BFG)
- [ ] Force push
- [ ] Notify anyone who may have cloned the repo
- [ ] Generate a new credential and store it securely
- [ ] Add `.gitignore` rules to prevent recurrence
- [ ] Consider enabling GitHub secret scanning
