---
title: "Running GitHub Actions on Your Own Infrastructure with Docker"
date: 2021-08-18
categories:
  - infrastructure
tags:
  - docker
  - github-actions
  - ci
  - self-hosted
repo: https://github.com/weisser-dev/github-actions-runner-docker
read_time: true
---

GitHub-hosted Actions runners are convenient but come with limitations: you get a fresh machine each time but no persistent state, limited compute for intensive workloads, and usage minutes that count against your plan. Self-hosted runners solve all of these but typically require you to install the runner software directly on a server. The github-actions-runner-docker project is a Dockerfile that containerizes the GitHub Actions runner, making it easier to manage, isolate, and run alongside other workloads.

The Dockerfile installs the GitHub Actions runner binary, configures it to connect to a specified repository or organization, and runs it as a non-root user. Docker-in-Docker support is included for workflows that need to build and run containers as part of CI. Environment variables are used for the GitHub registration token and runner configuration, so the same image can be registered to different repositories without rebuilding.

Security is the primary consideration when running self-hosted runners. GitHub's own documentation warns that pull request workflows on public repositories should not use self-hosted runners, because malicious code in a PR could execute on your infrastructure. For private repositories or organization-level runners with restricted access, the risk profile is acceptable. The containerized approach adds one more layer of isolation — the runner process and its dependencies are confined to the container filesystem, and the container can be rebuilt clean between sensitive workloads.

The cost savings for teams with significant CI workloads can be substantial. GitHub's free tier and team plans have finite included minutes, and the overage pricing adds up for compute-intensive builds. A self-hosted runner on a VPS or spare server runs continuously for a fixed monthly cost, and the hardware can be right-sized for your actual workload rather than the one-size-fits-all GitHub-hosted spec. For specialized workloads — GPU-accelerated builds, large memory requirements, specific OS versions — self-hosted is often the only practical option.
