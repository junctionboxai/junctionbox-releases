# JunctionBox — Visual Guide

A screenshot tour of every major part of JunctionBox. This is the "show me" companion to [`USER_GUIDE.md`](USER_GUIDE.md), which has the full task-oriented detail for each feature — this doc is for getting oriented fast, or for showing someone what JunctionBox actually looks like before they install it.

All screenshots below are from a real running instance with real agents, real providers, and real completed runs — nothing here is mocked up.

## Contents

- [Dashboard](#dashboard)
- [Models: connecting AI providers](#models-connecting-ai-providers)
- [Agents](#agents)
- [Chats](#chats)
- [The output panel](#the-output-panel)
- [Terminal access from a chat](#terminal-access-from-a-chat)
- [Screen sharing from a chat](#screen-sharing-from-a-chat)
- [Compare](#compare)
- [Teams and the Orchestrator](#teams-and-the-orchestrator)
- [Run History](#run-history)
- [Memory](#memory)
- [Schedules](#schedules)
- [Webhooks](#webhooks)
- [Telegram and iMessage](#telegram-and-imessage)
- [MCP Servers](#mcp-servers)
- [Plugins](#plugins)
- [Boxes: remote machines and terminals](#boxes-remote-machines-and-terminals)
- [Licensing](#licensing)
- [System Operations](#system-operations)

## Dashboard

The landing page: how many agents, providers, and MCP servers you have configured, a 7-day activity chart, which agents are doing the most work, and the most recent runs at a glance.

![Dashboard](images/dashboard.png)

## Models: connecting AI providers

**Models** in the sidebar is where every provider lives. The local CLI tools (Claude Code, Codex, Grok) are **auto-detected** — if you're already logged into one on this machine, JunctionBox finds it and marks it `detected`, with no API key to paste in anywhere. Cloud API providers (Anthropic, OpenAI, xAI) and Ollama (local or remote) sit right alongside them.

![Models](images/models.png)

This is also what makes mixed-provider teams possible: one agent can run on your Claude subscription, another on your ChatGPT subscription via Codex, another on Grok, another on a fully local Ollama model — all in the same JunctionBox instance, side by side.

## Agents

Each agent is a named configuration: provider/model, system prompt, permission profile, and a set of optional capabilities (memory, structured identity, delegation). The card shows its provider and model at a glance.

![Agents](images/agents.png)

## Chats

The main way you talk to an agent — streamed responses, markdown rendering, per-turn timing and cost, and the name you gave JunctionBox for yourself worked into every reply.

![Chats](images/chats.png)

## The output panel

Any background job — a scheduled run, a plugin action, a long-running task — can be popped open as a swing-out panel on the right side of the screen without leaving whatever page you're on. It streams the real activity log and stays docked while you keep working elsewhere in the app.

![Output panel](images/output-drawer.png)

## Terminal access from a chat

From inside a chat, if the agent is tied to a registered machine ("Box"), you can open a real interactive terminal to that machine as its own tab — right next to the chat tab, no separate app or SSH client needed.

![Terminal from chat](images/terminal.png)

## Screen sharing from a chat

Full remote control — mouse and keyboard, not just a view — of any registered Box, in its own tab right alongside the chat and terminal tabs. Nothing is installed permanently: on Linux a VNC server is set up fresh for the session and torn down when you close the tab, and on macOS it's the OS's own built-in Screen Sharing, switched on only for the session and off again afterward. Works on the machine JunctionBox itself runs on too, and from a phone or tablet browser, with a tap-to-type on-screen keyboard button since there's no physical keyboard to use.

![Screen share from chat](images/screen-share.png)

## Compare

Send the same prompt to 2–4 agents at once and watch their responses stream side by side — useful for picking a model, or sanity-checking a prompt change across providers before committing to it.

![Compare](images/compare.png)

## Teams and the Orchestrator

Agents on the same **Team** can see and delegate work to each other; outside a shared team they don't know the other exists. The **Orchestrator** page shows this happening live — the originating task, every delegated sub-task, and each one's status, in real time.

![Teams](images/teams.png)

![Orchestrator](images/orchestrator.png)

## Run History

Every single agent execution, filterable by agent and status, with token counts and timing — click into any row for the full output, activity log, and metadata.

![Run History](images/run-history.png)

## Memory

Long-term facts and preferences agents can draw on across conversations — but only after you approve them. Memory capture and memory injection are two separate, off-by-default toggles, so nothing is remembered or used automatically unless you turn it on.

![Memory](images/memory.png)

## Schedules

Run an agent's prompt automatically on a repeating interval — a daily summary, a recurring check, anything you'd otherwise have to trigger by hand. A schedule that fails repeatedly auto-pauses rather than failing silently forever.

![Schedules](images/schedules.png)

## Webhooks

Give any agent a public, secret-protected URL that triggers a run from outside JunctionBox entirely — wire it into a CI pipeline, a form submission, or any other automation.

![Webhooks](images/webhooks.png)

## Telegram and iMessage

Connect agents to messaging channels you already use. Telegram bots are configured per-agent with an allowlist of trusted chat IDs; iMessage integrates with existing conversations on a connected Mac.

![Telegram](images/telegram.png)

![iMessage](images/imessage.png)

## MCP Servers

Install Model Context Protocol tool servers from a built-in catalog or the public MCP Registry, and any capable agent can use their tools immediately.

![MCP Servers](images/mcp-servers.png)

## Plugins

Plugins are self-contained packages that extend JunctionBox with entirely new capabilities — their own pages, their own backend, their own agent-facing tools. Install one from a `.zip`, and it gets its own place in the sidebar, like **Comic Studio** below.

![Plugins](images/plugins.png)

![Comic Studio plugin](images/comic-studio.png)

## Boxes: remote machines and terminals

**Boxes** are connection records for machines JunctionBox can reach over SSH — this host, seeded automatically, or any remote machine you add. From here you can test connectivity, open a terminal directly, or generate and install an SSH key through a guided flow.

![Boxes](images/boxes.png)

## Licensing

Settings shows your current tier, how many active agent slots you're using, and lets you upgrade, manage your subscription, or deactivate the current device — all through a Stripe-hosted flow that never exposes payment details to JunctionBox itself.

![Licensing](images/settings-license.png)

## System Operations

The one place a privileged-mode agent can ever touch the host system — and even then, nothing runs from a tool call alone. A human reviews the exact script text here and approves it before anything executes, server-side, never inside the agent's own sandbox.

![System Operations](images/system-ops.png)
