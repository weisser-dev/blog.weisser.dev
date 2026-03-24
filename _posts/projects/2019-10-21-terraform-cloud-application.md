---
title: "Terraform on GCP: Spinning Up a Kubernetes Cluster as Code"
date: 2019-10-21
categories:
  - infrastructure
tags:
  - terraform
  - gcp
  - kubernetes
  - infrastructure-as-code
repo: https://github.com/weisser-dev/terraform-cloud-application
read_time: true
---

The terraform-cloud-application repository contains the infrastructure code for the cloud application tutorial series — Terraform HCL files that provision a Google Kubernetes Engine cluster on GCP, set up networking, and configure the supporting services needed to run containerized microservices in a production-ready way. This is the infrastructure layer that the Node.js and Java microservice blueprints deploy into.

The Terraform configuration covers the core GCP resources: a VPC network and subnets, a GKE cluster with a separately managed node pool (which allows node pool upgrades without recreating the cluster), Cloud SQL for the database backend, and the IAM bindings that grant the cluster's service account the permissions it needs. Everything is parameterized with Terraform variables so the same configuration can provision a small development environment or a larger staging/production setup by changing variable values.

Infrastructure as code with Terraform provides a few concrete benefits over click-ops in the cloud console. The configuration is reviewable — a colleague can read the HCL and understand exactly what resources exist and how they're connected. Changes are visible as diffs before they're applied. The state file tracks what Terraform manages, so you can delete the entire environment with a single `terraform destroy` and know that every resource has been cleaned up. Drift — when the live infrastructure diverges from the configuration — is detectable and correctable.

The GKE-specific considerations in the configuration are worth noting. Node auto-upgrade is enabled with a maintenance window, preemptible nodes are used for the dev environment to reduce cost, and the cluster is configured with Workload Identity so pods can access GCP APIs without hardcoded service account keys. These settings aren't required for a cluster to work but represent the configuration choices that matter for a production workload.
