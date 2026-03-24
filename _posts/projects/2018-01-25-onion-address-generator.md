---
title: "Generating Custom .onion Addresses with Shallot"
date: 2018-01-25
categories:
  - operations
tags:
  - shell
  - tor
  - onion
  - privacy
repo: https://github.com/weisser-dev/OnionAddressGenerator
read_time: true
---

Tor hidden service addresses are generated from RSA key pairs: the address is derived from the public key, which means you can't choose an arbitrary address — you generate key pairs until you find one whose derived address matches a desired prefix. Shallot is a C tool that does this efficiently using brute-force search with some algorithmic optimizations. OnionAddressGenerator is a shell script wrapper around Shallot that automates generating multiple addresses with a given prefix pattern and saves both the address and the corresponding key pair.

The mathematics here are worth understanding. A v2 .onion address is 16 base32-encoded characters derived from the SHA1 hash of the RSA public key. Finding an address with a specific 4-character prefix requires checking roughly 32^4 ≈ 1 million key pairs on average. Shallot is fast enough that this takes seconds to minutes on modern hardware. A 6-character prefix requires about 1 billion checks and becomes impractical on a single machine. This is the fundamental tradeoff in vanity address generation.

The shell script handles the operational side: running Shallot with the specified pattern, detecting when a match is found, saving the hostname and private key to a timestamped directory, and optionally continuing to generate additional matching addresses. This is useful when you want multiple address options to choose from — generate 5 matching addresses, evaluate which looks most memorable or trustworthy, and deploy that one.

This project was part of a series of posts about Tor hidden services and self-hosted infrastructure. The practical use case is any operator who wants a hidden service address that's more recognizable or memorable than a random string — which is most operators who care about user trust. A prefix that clearly identifies the service (first letters of the service name, for example) is harder to typo and easier to verify visually than a purely random address.
