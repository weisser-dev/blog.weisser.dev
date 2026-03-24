---
title: "Connecting Open WebUI to AWS Bedrock Knowledge Base for RAG"
date: 2025-07-14
categories:
  - ai
  - infrastructure
  - python
tags:
  - aws
  - bedrock
  - python
  - open-webui
  - rag
repo: https://github.com/weisser-dev/AWS-Bedrock-Knowledge-Base-Function
read_time: true
---

AWS Bedrock Knowledge Base is Amazon's managed RAG (Retrieval Augmented Generation) service. You point it at an S3 bucket full of documents, it handles chunking, embedding, and indexing, and then you can query it with natural language. The catch is that it's exposed as an AWS API — useful if you're building a custom application, but not directly usable from a chat UI. This project bridges that gap: a Pipe class for Open WebUI that routes queries through a Bedrock Knowledge Base before generating a response.

Open WebUI's Pipe plugin system lets you intercept the message flow between the user and the underlying model. A Pipe receives the user's message, can call external APIs, augment the context, and then pass the enriched prompt to the model. For RAG, this is exactly the right hook: intercept the query, retrieve relevant document chunks from the Knowledge Base, prepend them to the system message, and let the model generate a grounded answer. The implementation uses `boto3` under the hood and requires standard AWS credentials — IAM role, access keys, or whatever credential chain your environment provides.

The architecture has a few interesting details. Knowledge Base responses come back as source citations with passage text and document metadata. The Pipe formats these into a clean context block that the model can reference, and also appends the citations to the response so the user can see which documents informed the answer. This is important for enterprise use cases where auditability matters — you want to know not just what the model said, but which document it pulled from.

The practical use case for this is enterprise document Q&A. A team maintains a knowledge base of internal documentation, runbooks, or policy documents in S3. The Bedrock Knowledge Base handles the embedding and retrieval infrastructure. This Pipe lets any Open WebUI user query that knowledge base through a familiar chat interface, with the underlying LLM handling answer synthesis. The combination is meaningfully easier to maintain than a custom RAG pipeline, and the managed embedding refresh means the knowledge base stays current automatically when documents are updated.
