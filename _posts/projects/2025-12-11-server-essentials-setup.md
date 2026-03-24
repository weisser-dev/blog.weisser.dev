---
title: "My Server Essentials Setup: Automating a Fresh VPS"
date: 2025-12-11
categories:
  - infrastructure
  - operations
tags:
  - linux
  - server
  - automation
  - infrastructure
read_time: true
---

Every time I provision a new VPS, there's a predictable set of tasks: update the package list, install essential tools, harden SSH, set up a firewall, configure fail2ban, install nginx, add certbot, set up a non-root user, configure log rotation, install a monitoring agent. Doing all of this manually takes about an hour and is error-prone. The server-essentials project is an idempotent setup script that does it all in one shot.

Idempotency is the key property of a good server setup script. Running the script on an already-configured server should produce the same end state as running it fresh — no duplicate entries, no service restarts, no errors when a package is already installed. This means using package manager checks (`dpkg -l` or `apt list --installed`) before installing, checking for existing configuration blocks before adding them, and using systemctl `is-active` checks before restarting services. The script can be run again safely after an update to add new components.

The security hardening section covers the most common attack surface areas. SSH configuration changes include disabling password authentication (key-only login), disabling root login, restricting the `AllowUsers` list, and setting a custom port. UFW firewall configuration allows SSH on the custom port, HTTP, HTTPS, and blocks everything else. Fail2ban gets configured for SSH with aggressive thresholds — five failed attempts triggers a 24-hour ban — and for nginx to catch credential stuffing attempts against web applications.

Nginx is configured as a reverse proxy with sensible defaults: HTTP to HTTPS redirect, HSTS header, X-Frame-Options, X-Content-Type-Options, and a default server block that returns 444 for requests with unrecognized hostnames. Certbot is installed via snap with the nginx plugin, so adding SSL to a new vhost is a single command. The monitoring agent setup is environment-specific, but the script includes hooks for common options. The whole setup takes less than five minutes on a freshly provisioned Ubuntu LTS instance.
