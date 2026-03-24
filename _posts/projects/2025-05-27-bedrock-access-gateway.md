---
title: "Bedrock Access Gateway: OpenAI-Compatible APIs for Amazon Bedrock"
date: 2025-05-27
categories:
  - ai
  - infrastructure
  - python
tags:
  - aws
  - bedrock
  - python
  - openai
  - api-gateway
repo: https://github.com/weisser-dev/bedrock-access-gateway
read_time: true
---

One of the most practical problems when adopting Amazon Bedrock is that the ecosystem around it assumes you're using the AWS SDK directly. Most open-source tooling — LangChain, LiteLLM, Open WebUI, dozens of smaller projects — is built against the OpenAI API specification. If you want to use those tools with Bedrock models, you're either patching in Bedrock-specific adapters everywhere or maintaining a translation layer. The Bedrock Access Gateway is that translation layer: a Python service that exposes an OpenAI-compatible REST API and proxies requests to Bedrock on the backend.

The gateway implements the core OpenAI endpoints: `/v1/chat/completions`, `/v1/models`, and `/v1/embeddings`. Client applications send requests in exactly the OpenAI format — the same JSON structure, the same authentication header pattern — and the gateway handles the translation to Bedrock's `InvokeModel` and `Converse` APIs. Model names are mapped from OpenAI identifiers to their Bedrock counterparts, or you can pass Bedrock model IDs directly if you're already aware of them.

Streaming is one of the more technically interesting parts of the implementation. OpenAI's streaming API uses Server-Sent Events with delta chunks in a specific format. Bedrock has its own streaming response format with different chunking semantics. The gateway converts Bedrock's streaming output into the SSE format that OpenAI clients expect, handling partial tokens, finish reasons, and the final `[DONE]` sentinel correctly. Getting this right took careful attention to the OpenAI streaming spec.

For teams that are already invested in the OpenAI SDK or have tooling built around OpenAI's API format, the gateway provides a migration path to Bedrock without rewriting integrations. You change a base URL and an API key, and your existing OpenAI code hits Bedrock instead. This is also useful for cost experimentation — you can run the same prompts against multiple Bedrock models by just changing the model parameter, without touching application code. Self-hosted, stateless, and deployable as a container in any environment that can reach AWS.
