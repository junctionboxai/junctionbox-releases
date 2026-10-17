# JunctionBox — User & Admin Guide

This is a task-oriented guide to actually using JunctionBox, day to day. For a screenshot tour of what's described below, see [`VISUAL_GUIDE.md`](VISUAL_GUIDE.md). For installation, see `deploy/README-release.md`. For an exhaustive, source-verified technical catalog of every feature and its implementation, see `FUNCTIONALITY.md` — this guide links out to it where more depth is useful, rather than repeating it.

JunctionBox is single-user software (one password, no roles) — there's no separate "admin" account. This guide covers both everyday use and the administrative tasks (backups, security, licensing) the same person is responsible for.

## Contents

- [Getting started](#getting-started)
- [Core concepts](#core-concepts)
- [Providers: connecting AI models](#providers-connecting-ai-models)
- [Creating and configuring agents](#creating-and-configuring-agents)
- [Chatting with agents](#chatting-with-agents)
- [Comparing agents side by side](#comparing-agents-side-by-side)
- [Delegation and Teams](#delegation-and-teams)
- [Memory and agent identity](#memory-and-agent-identity)
- [Scheduling recurring work](#scheduling-recurring-work)
- [Telegram](#telegram)
- [Webhooks](#webhooks)
- [MCP tools and plugins](#mcp-tools-and-plugins)
- [Machines ("Boxes") and terminals](#machines-boxes-and-terminals)
- [Screen sharing](#screen-sharing)
- [Licensing: Free vs. Pro](#licensing-free-vs-pro)
- [Administration](#administration)
- [Troubleshooting](#troubleshooting)

## Getting started

1. Install JunctionBox per `deploy/README-release.md`, then open `http://127.0.0.1:8000` **on that machine**.
2. On first visit you'll set an access password (8+ characters) and accept the EULA — nothing else about JunctionBox works until it's done. This also works through the HTTPS proxy below, from any device on your LAN, so set a real password promptly after install.
3. Log in with that password going forward. There's no "forgot password" flow — if you lose it, you'd need direct access to the machine to reset it (see Administration below).
4. You'll land on the **Dashboard**: a summary of agents, providers, MCP tools, and recent activity, with a 3-step getting-started checklist until your first run exists.
5. A **JunctionBox Support** agent is already there, auto-created — ask it how to use JunctionBox, or whether core services are running, at any time. It's protected (can't be deleted or have its prompt edited) and never appears as a delegation target for your other agents.

The next three sections — Providers, Agents, Chat — are the minimum to get a working agent talking to you.

## Core concepts

- **Provider**: a way of running a model — a cloud API (Anthropic, OpenAI, xAI/Grok), a local CLI subscription login (Claude Code, Codex, Grok), or Ollama (local or remote). You configure providers once; you then choose which one each agent uses when you set it up.
- **Agent**: a named configuration — which provider/model, a system prompt, a permission profile, optional sandboxing/working directory, and a pile of optional toggles (memory, identity, delegation). You can have as many agent *configurations* as you like; the Free/Pro tier only limits how many can be **active** (enabled) at once.
- **Run**: one execution of an agent against a prompt. Runs are durable — queued in the database and executed by the background daemon (`junctionboxd`), so they survive a browser refresh or even a restart of the web server.
- **Team**: a group of agents that can discover and delegate to each other. Outside a shared team, agents don't know about each other at all — this is the only thing that limits agent-to-agent delegation; it has no effect on you running an agent directly.

## Providers: connecting AI models

Settings isn't where providers live — go to **Models** in the sidebar.

- **Local CLI logins** (Claude Code, Codex, Grok): if you're already logged into one of these tools on this machine, JunctionBox detects it automatically — nothing to configure. Click **Test** to confirm.
- **Cloud APIs** (Anthropic, OpenAI, xAI): paste an API key and save. JunctionBox stores it encrypted and only uses it for your own agent runs.
- **Ollama**: point JunctionBox at your Ollama server (defaults to `http://localhost:11434`); works with a remote Ollama server too, with an optional auth key.

Only providers JunctionBox considers "configured" show up when you go to create an agent.

## Creating and configuring agents

Go to **Agents** → **New Agent**.

- **Name, description, provider, model, system prompt** — the basics.
- **Permission profile** controls how much of your filesystem a local CLI agent (Claude/Codex/Grok) can touch: **Restricted** (read-only), **Workspace** (only the agent's own working directory is writable), or **Unrestricted** (full host access, for compatibility — use deliberately, not by default).
- **Working directory** — where a local CLI agent operates. Leave blank to use a sensible default.
- **Timeout** — how long a single run can take before JunctionBox gives up (30 seconds to 2 hours).
- Optional toggles worth knowing about:
  - **Operating context** — only for an agent you're using to work on JunctionBox's own source code. Leave off for a normal agent.
  - **Structured identity** — a richer persona (role, tone, values, boundaries) beyond the free-text system prompt, editable from the agent card's Identity dialog, with full version history.
  - **Memory** — see [Memory and agent identity](#memory-and-agent-identity).

Click **Run** on any agent card to jump straight into a new Chat tab with it.

## Chatting with agents

The **Chats** page is the main way you interact with agents.

- Multiple tabs, each with its own agent and conversation. Enter sends, Shift+Enter inserts a newline.
- Responses stream live. The **Activity** drawer (collapsed by default) shows what the agent is doing — tool calls, delegation, retries — without exposing raw private reasoning.
- You can stop a running response, copy any message or the whole transcript, attach files/images, and open an interactive terminal as its own tab.
- **Save** a conversation as a named thread (Threads page) to revisit later; **New Conversation** starts fresh with the same agent.
- By default chat history lives in your browser only (`localStorage`) — clearing browser data loses it. Turn on **server-side conversations** (a Settings toggle) to make conversations durable in the database instead, with cross-browser access and an import flow for anything already saved locally.

## Comparing agents side by side

**Compare** runs one prompt against several agents at once, streaming each response in its own column — useful for picking a model/provider or sanity-checking a prompt change across agents.

## Delegation and Teams

Anthropic, Ollama, and Claude CLI agents can **delegate** a sub-task to another agent directly inside their own conversation, without you doing anything — this is what makes multi-agent workflows possible.

- An agent can only see and delegate to agents it shares a **Team** with. Put two agents on the same team to let them collaborate; leave an agent off every team (or give it an empty-roster team) to keep it isolated.
- Delegation depth is capped at 3 levels to prevent runaway chains.
- Watch delegation happen live on the **Orchestrator** page — a graph of the originating agent, each delegated task, and its status.
- The Teams page also has a convenience "apply to team" action to flip the operating-context/plugin-creation-context toggles for every member at once.

## Memory and agent identity

Two independent, off-by-default toggles let agents remember things across conversations:

- **Memory capture** — JunctionBox proposes candidate memories (facts, preferences, decisions) from what you say in a run, using pattern matching (not an AI guess) so it stays predictable. Nothing is remembered automatically — review and approve/reject candidates on the **Memory** page.
- **Memory injection** — once a memory is approved, relevant ones get pulled into future prompts automatically, scoped either to one agent or shared globally.

**Structured identity** (per agent) is a separate, more deliberate persona definition — role, tone, values — with its own version history, diffing, and restore, edited from each agent's Identity dialog.

## Scheduling recurring work

**Schedules** runs an agent's prompt on a repeating interval (minimum one minute) — a daily summary, a recurring check-in, anything you'd otherwise have to trigger by hand.

- **Test** fires the prompt once, right now, without affecting the schedule's own timing or reliability tracking — use it to check a schedule actually does what you expect before trusting it unattended.
- A schedule that fails repeatedly auto-pauses (default: 5 consecutive failures) rather than silently failing forever; resume it manually once you've fixed the problem.
- Optional **proactive decision mode**: the scheduled agent can decide for itself whether a given run is worth notifying you about (`notify`) or not (`silent`), with deduplication so the same recurring condition doesn't page you every single run, and optional quiet hours.

## Telegram

Connect one or more Telegram bots (via @BotFather tokens) to talk to a specific agent from your phone. Configure under **Telegram** in the sidebar: add a bot, set its target agent, and add the Telegram chat IDs allowed to use it — anyone not on that allowlist is silently ignored. Each bot is independent; a message to one bot never reaches another bot's agent or trusted-sender list.

## Webhooks

**Webhooks** gives any agent a public, secret-protected URL that triggers a run from outside JunctionBox entirely — useful for wiring JunctionBox into some other automation (a CI pipeline, a form submission, another app). Rotate the secret any time from the same page.

## MCP tools and plugins

- **MCP** (sidebar) manages Model Context Protocol tool servers — browse a built-in catalog or the public MCP Registry, install one, and any Anthropic/Ollama/Claude-CLI agent can use it.
- **Settings → Plugins** installs self-contained plugin ZIPs (a separate distribution from JunctionBox core — see `FUNCTIONALITY.md`'s Plugin architecture section for what one actually is and the trust model involved). Installing a plugin's backend code requires a restart before its routes are live.
- **A plugin runs with the same privileges as JunctionBox itself.** There's no sandbox between a plugin and your data — install one only from a source you trust, the same judgment call as installing a browser extension.

## Machines ("Boxes") and terminals

**Boxes** are machine connection records — this host (seeded automatically) or any remote machine over SSH. From Boxes you can open a real interactive terminal to any configured machine, or set up SSH access with a guided key-generation flow. An agent can be assigned to a box two different ways:

- By default, the agent is just told about the box (connection details in its prompt) and decides for itself whether to SSH there.
- **Remote execution** (`run_remote_on_box`, set per agent) actually moves the agent's own execution onto that box — its filesystem/shell tools genuinely operate there, not a local sandbox.

## Screen sharing

From a Box's card, click **Screen Share** for full mouse-and-keyboard remote control of that machine, in its own tab right alongside Chat and Terminal — not just a view, real input. This works for any registered Box, including the machine JunctionBox itself runs on ("Local").

Nothing is installed permanently:

- **Linux**: a VNC server is set up fresh when you open the tab and torn down completely when you close it. Nothing is left running or installed afterward beyond the package itself (installed once, like any other apt/dnf package).
- **macOS**: no third-party software at all — it's the Mac's own built-in Screen Sharing (the same thing "Remote Management" in System Settings controls), switched on only for the session with a fresh one-time password, and switched off again when you close the tab.

A few things worth knowing:

- On a **phone or tablet**, there's no physical keyboard to type with — a keyboard icon in the screen-share tab opens a tap-to-type input.
- The **first** time you screen-share into a given Mac, macOS requires the Screen Recording permission to have been granted at least once *interactively, at that Mac itself* (System Settings → Privacy & Security → Screen Recording) — this can't be done remotely or via SSH by design (Apple's own hardening, so SSH access alone can never silently turn on remote screen viewing). If a session connects but shows a black screen, this is almost always why — go grant it once at the machine and it's a one-time fix per Mac.
- Screen sharing to the local box requires either passwordless `sudo` or a stored sudo password on that Box's own connection record (Boxes → Local → Edit) — without one of those, starting a local session will tell you so directly.

## Licensing: Free vs. Pro

- **Free**: up to 2 active agents, no account or payment needed, works fully offline.
- **Pro** ($79/yr): unlimited active agents.

Settings → License shows your current tier and usage, and has Upgrade/Manage Subscription/Deactivate Device actions. Full details — activation steps, cancellation behavior, what data this involves — are in `deploy/README-release.md`'s Licensing section and `deploy/PRIVACY_POLICY.md`.

If you're at the Free limit, creating a 3rd agent still works (configurations are never limited) — only *enabling* it is blocked, with a prompt to upgrade.

## Administration

### Backups and restore

JunctionBox backs up its database automatically (daily, 14 archives kept by default) and you can trigger one immediately from **Settings**. A backup includes the database and the encryption key needed to read its encrypted fields — **the key is operationally critical**: losing `~/.junctionbox/master.key` without a backup makes stored credentials (API keys, box passwords, webhook secrets) unrecoverable.

Restoring requires typing the exact archive name, re-entering your password, and refuses to run while any agent run is active — it also takes a fresh safety backup first, so a bad restore is itself recoverable.

### Data retention

Settings lets you configure how long completed runs/tasks/logs are kept (independently of each other) and preview what a cleanup would actually delete before running it. Cleanup re-verifies your password and takes a safety backup first, same as restore.

### Security and sessions

- Settings shows every active login session (address, device, last activity) and lets you revoke any of them; changing your password revokes all of them at once.
- Every meaningful action (not just logins) is recorded in a secret-free audit log, visible in Settings.
- `junctionbox-api` itself only ever listens on `127.0.0.1` — nothing outside this machine can reach it directly, and this never changes. Install sets up a separate, self-signed-HTTPS Caddy proxy in front of it automatically (`install-https-proxy.sh`, runs as part of install, safe to re-run), reachable at `https://<this machine's LAN IP>:8443` (or the next free port, if something else already had 8443) — that's the one thing actually reachable from another device. First visit from a new device shows a one-time certificate warning (self-signed, no public CA) — expected, accept it once. See `DEPLOYMENT_SECURITY.md` for the reasoning.

### System diagnostics

Settings → system diagnostics reports database health, encryption-key status, storage, and detected local CLI installs — the first place to check if something seems broken, before digging into logs.

### Exporting/importing

**Settings → Export** produces a portable JSON snapshot of agents, evaluations, and schedules (not secrets) you can import into another install.

## Troubleshooting

For service-level problems (won't start, port conflicts, logs) see `deploy/README-release.md`'s Troubleshooting section — that covers the systemd/launchd layer underneath JunctionBox, before you even reach the web UI.

Application-level starting points:

- **Ask the JunctionBox Support agent** — it's specifically built to answer "how do I..." questions and do basic health checks without you needing to find the right doc section.
- **Agent won't start / 402 error**: you've hit the Free-tier 2-active-agent limit — see Licensing above.
- **An agent can't see / delegate to another agent**: check they share a Team — delegation is invisible outside shared teams by design, not a bug.
- **A local CLI agent (Claude/Codex/Grok) can't reach a file or tool**: check its permission profile and working directory — Restricted mode is read-only and Workspace mode only allows its own directory, by design.
- **Something seems to be hanging**: turn on **Stall detection** (Settings, off by default) so a stuck run gets flagged with a reason and recovery options instead of running forever.
- Check Settings → system diagnostics and the audit log before assuming something is broken versus working as configured.
