---
title: "OpenClaw Setup on VPS"
date: 2026-02-24
categories:
  - openclaw
tags:
  - openclaw
  - vps
  - setup
  - deployment
  - nginx
  - linux
read_time: true
excerpt: "Complete guide to installing and configuring OpenClaw on a VPS – Node.js 22, daemon setup, Nginx reverse proxy and firewall configuration."
---

This guide walks you through installing OpenClaw on a VPS (Virtual Private Server) like Hetzner, DigitalOcean, or similar providers.

## Prerequisites

- **VPS with Ubuntu 22.04+ or Debian 12+**
- **Root or sudo access**
- **Domain name** (optional, for remote access)
- **At least 2GB RAM** (4GB recommended for model inference)

## Step 1: Install Node.js 22

OpenClaw requires Node.js 22 or newer.

```bash
# Using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
nvm alias default 22

# Verify installation
node --version  # Should show v22.x.x
npm --version
```

## Step 2: Install OpenClaw

```bash
# Install OpenClaw globally
npm install -g openclaw

# Verify installation
openclaw --version
```

## Step 3: Run the Onboarding Wizard

```bash
openclaw onboard --install-daemon
```

The wizard will guide you through:

1. **Gateway configuration** (port, bind address, auth)
2. **Model provider setup** (OpenAI, Qwen, Anthropic, etc.)
3. **Channel configuration** (Telegram, Discord, WhatsApp, etc.)
4. **Daemon installation** (systemd service)

## Step 4: Configure Gateway for Remote Access

Edit `~/.openclaw/openclaw.json`:

```json
{
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "0.0.0.0",
    "auth": {
      "mode": "token",
      "token": "your-secure-token-here"
    },
    "tailscale": {
      "mode": "off"
    }
  }
}
```

## Step 5: Configure Firewall

```bash
# Allow OpenClaw gateway port
sudo ufw allow 18789/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

## Step 6: Install and Configure Nginx (Optional, for HTTPS)

```bash
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

sudo nano /etc/nginx/sites-available/openclaw
```

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/openclaw /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com
```

## Step 7: Verify Gateway Status

```bash
openclaw gateway status
openclaw logs --follow
curl http://127.0.0.1:18789/health
```

## Step 8: Connect Channels

After gateway is running, configure your channels:

```bash
# Telegram Bot
openclaw configure --section telegram

# Discord Bot
openclaw configure --section discord
```

## Security Considerations

1. **Use strong auth tokens** – Generate with `openssl rand -hex 32`
2. **Enable firewall** – Only allow necessary ports
3. **Use HTTPS** – Always use reverse proxy with SSL for production
4. **Regular updates** – Run `npm update -g openclaw` periodically
5. **Monitor logs** – Check `openclaw logs` for suspicious activity

## Troubleshooting

```bash
# Gateway won't start – check if port is in use
sudo lsof -i :18789

# Check logs
openclaw logs --tail 100

# Restart daemon
openclaw gateway restart
```

## Next Steps

- [OpenClaw with Qwen (Free Models)](/blog/2026/02/24/openclaw-qwen-setup/)
- [OpenClaw Subagents](/blog/2026/02/24/openclaw-subagents/)
- [OpenClaw Model Fallback](/blog/2026/02/24/openclaw-fallback-models/)
