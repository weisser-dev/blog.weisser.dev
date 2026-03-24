---
title: "ELK Stack with Docker Compose: Practical Logging and Observability"
date: 2021-04-16
categories:
  - infrastructure
tags:
  - docker
  - elasticsearch
  - kibana
  - elk
  - monitoring
repo: https://github.com/weisser-dev/elastic-docker
read_time: true
---

The ELK stack — Elasticsearch, Logstash, and Kibana — is a standard combination for centralized logging and observability. Adding Beats (Filebeat, Metricbeat) completes the picture with lightweight data shippers that run on each host and forward logs and metrics to the central stack. Getting all of these running together with sensible configuration is non-trivial; the elastic-docker repository provides working docker-compose configurations that you can adapt rather than starting from scratch.

The core challenge with Elasticsearch in a self-hosted context is the memory configuration. Elasticsearch's JVM heap should be set to roughly half of the available system RAM (bounded by 30GB as a practical upper limit), and the underlying host needs `vm.max_map_count` set to at least 262144 or the container will fail to start with an error that's not immediately obvious to first-time users. The docker-compose files in this project set both the heap size and the sysctl value explicitly, which prevents the most common setup failure mode.

Single-node mode is the practical configuration for development and smaller production deployments. Elasticsearch's default cluster health check will report yellow in single-node mode because replicas cannot be assigned when there's only one node. This is expected and harmless, but it's confusing without explanation. The configurations include the `discovery.type: single-node` setting that suppresses this and skips the replica assignment logic, which clears the cluster to green health and removes the confusion.

Logstash pipeline configuration is where most of the customization lives. The example pipelines cover common inputs (Beats, syslog, file tailing), common filters (grok for log parsing, date parsing, field manipulation), and the Elasticsearch output. Kibana's index pattern setup and the basics of the Discover and Dashboard views are covered in the README. For teams getting started with centralized logging, having a working reference configuration to learn from is significantly faster than assembling it from scratch from the official documentation.
