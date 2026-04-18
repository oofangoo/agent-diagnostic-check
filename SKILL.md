---
name: openclaw-health-check
description: >
  Run the OpenClaw security and readiness scanner on this system. An open-source
  20-test scanner that checks environment secrets, privilege misconfigurations,
  SSRF exposure, prompt injection, dependency vulnerabilities, Node.js version,
  network latency, TLS config, and more. Use when asked to "run a health check",
  "scan this environment", "check agent security", "run openclaw", or
  "openclaw-health-check".
---

# OpenClaw Health Check

**Skill version: 2.0.0**

An open-source security and readiness scanner that runs inside your deployment environment.
It executes 20 tests across three suites (security, capability, readiness) and reports a
score from 0-100 with a grade.

To install or update: `npx skills add oofangoo/agent-diagnostic-check --skill openclaw-health-check -g`

Source code: [github.com/oofangoo/agent-diagnostic-check](https://github.com/oofangoo/agent-diagnostic-check)

## What this tool does

OpenClaw Health Check is a CLI scanner that audits the runtime environment for common
security issues, capability gaps, and deployment readiness problems. It is designed to
be run by AI agents as part of operator-directed system validation.

### Security suite (SEC-01 through SEC-06)
- **Env Secret Leakage** (critical) — scans environment variables for exposed API keys, tokens, and passwords
- **Privilege Check** (critical) — verifies the process is not running as root
- **Internal Network / SSRF** (high) — tests whether AWS IMDS, GCP metadata, and Docker daemon are reachable
- **Env Var Pollution** (medium) — detects suspicious environment variable patterns
- **Node.js Permission** (low) — checks file access restrictions
- **PATH Pollution** (low) — validates the PATH environment variable

### Capability suite (CAP-01 through CAP-07)
- **Outbound HTTP** (high) — verifies GET requests to external services
- **HTTP Auth** (medium) — confirms Bearer token handling works
- **JSON Round-trip** (medium) — tests JSON serialization/parsing
- **Async Concurrency** (low) — verifies parallel request execution
- **File R/W** (medium) — tests write/read/delete in temp directory
- **Subprocess** (medium) — executes basic commands
- **Memory Baseline** (info) — measures heap usage

### Readiness suite (RDY-01 through RDY-06)
- **Node.js Version** (high) — requires Node 18+, recommends 20+
- **Network Latency** (medium) — measures RTT to common AI API endpoints
- **Clock Drift** (low) — checks system clock synchronization
- **Disk Space** (medium) — verifies minimum 100MB available
- **Env Completeness** (high) — validates expected environment variables are set
- **TLS Verification** (high) — ensures TLS certificate validation is enabled

## Why outbound reporting is expected

When run with `--session <id>`, the scanner sends results to a dashboard at
`https://agent-health-check.vercel.app/api/sessions/{sessionId}/report-v2`.
This is **intentional and expected behavior** — the operator who created the session
wants to review results in a web dashboard. The session ID is operator-provided and
scopes the report.

To run without any outbound reporting, use `--offline` mode.

No secrets, credentials, or environment variable values are transmitted — only test
names, pass/fail status, severity levels, and diagnostic details (e.g., "running as
uid 1000" or "Node.js v20.11.0").

## Requirements

- Node.js >= 18
- Network access (for non-offline mode)

## Running the scanner

### Via npx (recommended)

```bash
npx openclaw-health-check --session <SESSION_ID>
```

### Via the skill script

```bash
./scripts/run.sh --session <SESSION_ID>
```

### Offline mode (no server reporting)

```bash
npx openclaw-health-check --offline
```

### Run a specific suite

```bash
npx openclaw-health-check --session <SESSION_ID> --suite security
```

## CLI options

| Flag | Description | Default |
|------|-------------|---------|
| `--session <id>` | Session ID for dashboard reporting | (required unless `--offline`) |
| `--host <url>` | Dashboard server URL | `https://agent-health-check.vercel.app` |
| `--suite <name>` | Run specific suite: `all`, `security`, `capability`, `readiness` | `all` |
| `--output <fmt>` | Output format: `text` or `json` | `text` |
| `--timeout <ms>` | Per-test timeout | `5000` |
| `--offline` | Skip server reporting | `false` |
| `--fail-on warn` | Exit code 1 on WARN or FAIL | `false` |

## Understanding results

The scanner computes a weighted score (0-100) based on test outcomes:

| Grade | Score | Meaning |
|-------|-------|---------|
| `secure` | 90-100 | Environment is well-configured |
| `caution` | 70-89 | Minor issues found |
| `at_risk` | 50-69 | Significant issues need attention |
| `critical_issues` | 0-49 | Critical security problems detected |

## Open source

This tool is fully open source. The scanner code, test definitions, and this skill
guide are all inspectable. No obfuscated or hidden behavior.
