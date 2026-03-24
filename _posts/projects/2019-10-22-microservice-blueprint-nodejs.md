---
title: "Node.js Microservice Blueprint with Express and MySQL"
date: 2019-10-22
categories:
  - javascript
  - microservices
tags:
  - node.js
  - microservices
  - express
  - mysql
  - rest-api
repo: https://github.com/weisser-dev/microservice_blueprint_nodejs
read_time: true
---

This is the Node.js counterpart to the Java microservice blueprint — the same REST API specification implemented with Express and a MySQL backend, designed to illustrate how the same problem looks in a different runtime. Where the Java version emphasizes type safety and explicit wiring, the Node.js version emphasizes speed of development, a small codebase, and minimal configuration overhead.

The application structure is intentionally flat: a few route files, a database module, a configuration module, and an entry point. Express handles the routing and middleware pipeline, `mysql2` provides the database connection pool with promise support, and environment variables handle all configuration — database credentials, port, any feature flags. The application reads configuration at startup and fails fast with a clear error if required environment variables are missing. This pattern is more important than it sounds; silent failures from missing configuration are a common source of mysterious bugs in containerized deployments.

Error handling in Express requires a bit of deliberate attention. Unhandled promise rejections in async route handlers don't automatically propagate to Express's error middleware in Express 4 (Express 5 fixes this). The blueprint wraps async route handlers in a utility that catches rejections and forwards them to `next()`, ensuring all errors are handled consistently and returned as proper JSON error responses rather than crashing the process or hanging the request.

The performance comparison between this and the Java embedded Jetty version is instructive. Node.js handles I/O-bound workloads (which most REST APIs are — you're waiting on database queries) with excellent efficiency due to the event loop model. Java has a startup time disadvantage but handles CPU-bound workloads better and benefits from JVM JIT compilation for sustained high throughput. For a typical CRUD microservice doing database queries and JSON serialization, the practical performance difference between the two is small enough that the team's existing expertise is a more important deciding factor.
