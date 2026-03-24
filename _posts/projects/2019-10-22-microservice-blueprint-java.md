---
title: "Lightweight Java Microservices Without Spring: Embedded Jetty Blueprint"
date: 2019-10-22
categories:
  - microservices
tags:
  - java
  - microservices
  - jetty
  - gradle
  - rest-api
repo: https://github.com/weisser-dev/microservice_blueprint_java
read_time: true
---

Spring Boot is the default choice for Java REST APIs, and for many projects it's the right choice. But Spring brings significant startup time, memory overhead, and a large transitive dependency tree. For small, focused microservices where you control the deployment environment, there's a case for a lighter approach. This blueprint provides a working REST API built with embedded Jetty, Jersey for JAX-RS annotations, Gson for JSON serialization, and a MySQL connector — all wired together without Spring.

The startup time difference is meaningful. A Spring Boot application with a moderate set of starters might take 5-10 seconds to start. An embedded Jetty application bootstrapped directly takes under a second. For a microservice that's restarted frequently — during deployments, container scheduling, or auto-scaling — this difference compounds. Cold start performance also matters for serverless and container-heavy deployment patterns where you can't assume a warm instance is waiting.

The project structure follows a clear layered architecture: resource classes (Jersey REST endpoints), service classes (business logic), repository classes (database access with raw JDBC or a lightweight helper), and a configuration class that wires them together. There's no magic here — every dependency is explicitly instantiated and wired. This explicitness is both the advantage and the limitation: you understand exactly what's running, but you lose the productivity shortcuts that Spring's auto-configuration provides.

This blueprint was built as a companion to a series of blog posts comparing different microservice implementation approaches. The same REST API — a simple CRUD service with a database backend — is implemented in Java with embedded Jetty, in Node.js with Express, and deployed with Terraform on GCP/Kubernetes. Comparing the implementations side by side is a useful exercise in understanding what different technology choices actually cost and gain you in practice.
