---
title: "Why I am building the Agentic Workflow Protocol"
date: 2026-11-25
lang: en
ref: agentic-workflow-protocol
categories: [projects, ai]
tags: [ai-agents, architecture, governance, open-source]
read_time: true
---

An agent can be impressive in a demo and still be difficult to operate as part of a larger system. Which tools can it use? What can it spend? Who owns the workflow, and when does a human need to approve a step? Those questions become harder to answer when the answers live in prompts, code and platform-specific configuration.

I started the [Agentic Workflow Protocol (AWP)](https://agenticworkflowprotocol.org/) as a personal project to explore a more explicit way to describe agentic workflows. The idea is to bring the work, its boundaries and its governance into a machine-readable description that people and tooling can inspect.

## A description, not another agent platform

AWP is an open specification, not a runtime or a hosted platform. A workflow description can express agents, tools and steps alongside aspects such as budgets, permissions, environments, ownership, risk and human approval. It also describes information that implementations can record for audit and reproducibility.

The distinction matters: **writing a permission or a budget into a document does not enforce it**. A runtime must interpret and enforce the rules, and teams still need to test the implementation, manage access and decide which policies apply. AWP does not make a system compliant by itself.

## How it relates to MCP and A2A

I see these as complementary layers. MCP provides a way for agents to interact with tools and resources; A2A addresses communication between agents. AWP focuses on describing the workflow around them: what should happen, under which constraints, and what needs to be recorded. The exact integration depends on the implementation rather than a promise that any combination will automatically work together.

## Why make the boundaries explicit?

Consider a workflow that examines a repository and proposes a fix. A human reviewing its configuration should be able to find the available tools, execution limits and approval requirements without reconstructing them from a long prompt. A validator can help check whether a description follows the schema; it cannot guarantee that the workflow is safe or that the runtime behaves correctly.

This is particularly useful to me when discussing agent systems across teams: it gives architecture, security and operations a shared artifact to question and improve. It is an approach to the problem, not the only possible one.

## Early stage and next steps

AWP is **a draft in the alpha stage**. Its formats and semantics can change, and the project does not yet claim production-ready interoperability. The repository includes the specification work and conformance material; an editor and validator are also available. Check the current project documentation for supported versions and limitations before experimenting.

A related [OpenAgentix News article on classifier models and autonomy levels](https://blog.openagentix.si/posts/classifier-models-and-autonomy-levels/) discusses one governance question that appears in this space. For the protocol itself, start with the [AWP website](https://agenticworkflowprotocol.org/) or the [source repository](https://github.com/agenticworkflowprotocol/agenticworkflowprotocol.org). Feedback and contributions are welcome.

## Sources

- Agentic Workflow Protocol, [project repository and README](https://github.com/agenticworkflowprotocol/agenticworkflowprotocol.org), accessed 25 November 2026.
- OpenAgentix News, [Classifier models and autonomy levels](https://blog.openagentix.si/posts/classifier-models-and-autonomy-levels/), accessed 25 November 2026.
