---
title: "Angular Docker: Filling the Gap with Automated Image Builds"
date: 2022-03-21
categories:
  - infrastructure
tags:
  - docker
  - angular
  - ci
  - automation
repo: https://github.com/weisser-dev/angular-docker
read_time: true
---

For a long time, there was no official Docker image for Angular development. If you wanted a consistent Angular build environment in CI or needed to containerize your development workflow, you had to maintain your own base image — which meant keeping up with Angular CLI version bumps, Node.js updates, and the dependency chain between them. The angular-docker project automates this: a GitHub Actions workflow runs on a schedule, builds an Angular Docker image with the latest stable CLI version, and pushes it to Docker Hub automatically.

The Dockerfile itself is straightforward: start from the official Node.js Alpine image, install the Angular CLI globally, set up a working directory, and expose a default port. The interesting engineering is in the automation layer. A cron-triggered GitHub Actions workflow checks the current Angular CLI version against the version in the published Docker Hub image. If they differ, it builds a new image, tags it with both the version number and `latest`, and pushes both tags.

This kind of maintenance automation is a good pattern for any project that tracks an upstream dependency. Manual update processes get neglected; automated ones don't. The cost of setting up the automation is paid once, and then you get correct, current images indefinitely. The GitHub Actions cron schedule can be tuned to run daily or weekly depending on how quickly you need to pick up new versions.

The image serves two main use cases. In CI pipelines, it provides a consistent Angular build environment without requiring Node.js or the Angular CLI to be installed on the runner. In development, it can be used as a base image for Angular project containers, which is useful for teams that want to ensure everyone is developing against the same CLI version. Since Angular is reasonably opinionated about CLI/project version compatibility, having a clean versioned image matters.
