# JunctionBox — Features

JunctionBox is a local-first AI agent orchestration platform. Your conversations, credentials, and run history live in a database on your own machine — not in a vendor's cloud. It runs multiple AI agents across any mix of providers, lets them delegate work to each other, remembers what matters across conversations, automates recurring work, and gives you real operational visibility into everything it's doing — with security defaults built for agents that can take real, consequential actions on your behalf.

## Model providers — bring your own, mix freely

JunctionBox doesn't lock you into one vendor or one way of paying for inference. Seven providers are built in, and different agents can run on different providers side by side:

- **Local CLI subscriptions** — Claude Code, Codex, and Grok, using the login you already have. No separate API key, no per-token billing on top of what you already pay for the subscription.
- **Local or remote Ollama** — run open-weight models on your own hardware, or point at an Ollama server elsewhere on your network. Ollama agents get the same delegation and tool-use capabilities as cloud agents.
- **Cloud APIs** — Anthropic, OpenAI, and xAI (Grok 4.5), using your own API keys, with credentials tested live before you save them.

Every CLI agent runs through its native permission system *and* an OS-level sandbox on top of it (see Security, below) — the CLI's own guardrails are never the only thing standing between an agent and your filesystem.

## Agents — precise control over what each one can do

- Give each agent its own provider, model, system prompt, execution timeout (30 seconds to 2 hours), and working directory.
- Choose a **permission profile** per agent: *Restricted* (read-only), *Workspace* (only the assigned directory is writable), or *Unrestricted* (full host compatibility) — enforced by the sandbox itself, not just requested of the model.
- A small, non-negotiable safety baseline (mask secrets, never claim success without verifying) is appended to every agent automatically, regardless of any other setting.
- Optionally bind an agent to a registered machine ("Box") — by default this just tells the agent how to connect over SSH and lets it decide whether to; a separate setting actually moves its execution onto that machine (see Machines, below).
- A built-in **JunctionBox Support Agent** is ready on first launch — ask it how to use JunctionBox or whether your services are healthy, with no setup required. It can't be deleted or have its prompt edited, and never appears as a delegation target for your other agents.

## Chat, comparison, and conversation history

- Multiple independent chat tabs, each tracking its own agent, with full streaming output and multi-turn history.
- A dedicated **Activity view** separates an agent's real-time tool calls, delegation, retries, and reasoning-phase status from its final answer — without ever forwarding an agent's private raw chain-of-thought.
- **Compare mode** runs one prompt against several agents at once, streaming every response in its own column — the fastest way to decide which model or prompt actually works best for a task.
- Attach files and images directly in chat; open a full interactive terminal — local or over SSH to any registered machine — as its own tab without leaving the conversation.
- Save any conversation as a named thread to revisit, rename, or continue later.
- Optional **server-side conversation persistence**: turn it on and every chat is mirrored durably, so it survives a browser switch or a cleared cache — JunctionBox even detects your existing local chat history and offers to import it, without deleting the original copy.

## Multi-agent orchestration and teams

This is where JunctionBox goes well beyond a single chat window:

- **Teams** scope delegation: an agent can only discover and hand off work to other agents sharing at least one team with it. Outside a shared team, an agent doesn't know another agent exists — enforced twice, independently, so a leaked agent ID from a memory or copied transcript can't be used to bypass team boundaries.
- Anthropic, Claude CLI, and Ollama agents get a live **Agent Directory** injected into their context, listing every teammate's name, model, and role — so an orchestrating agent genuinely knows who it can delegate to and why.
- Delegated work is tracked as durable, persistent task records — not just lines in a transcript — with retries, timeouts, and automatic recovery for stuck Ollama runners between attempts.
- Delegation depth is capped at three levels, enforced once centrally so the limit can never drift between the built-in orchestrator and the Claude CLI bridge.
- A live **Orchestrator graph** visualizes who delegated what to whom, with real-time state, retry counts, and the ability to drill into any task's full assignment, result, and originating run.

## Structured identity and long-term memory

- Give an agent a defined **role, tone, core values, and boundaries** through structured identity fields, layered on top of its free-text system prompt rather than replacing it. Every change is versioned — compare two versions field-by-field, test one against a real prompt, or restore an older one.
- **Long-term memory** lets agents (or your whole setup) remember facts, preferences, decisions, and relationships across conversations — typed, sourced, and scored by confidence and importance.
- Memory capture is deliberately deterministic (pattern-based, not model-guessed) and nothing is auto-approved: every captured memory sits in a review queue until you approve it, and anything that looks like a secret (API keys, tokens, card numbers) is never even suggested.
- When a new memory supersedes an old one, the old one is kept and marked superseded — never silently overwritten — so you always have a trail.
- A global profile (name, timezone, communication preferences, stable facts) is available to every agent, alongside memories scoped to just one agent.

## Automation: schedules, webhooks, and messaging

- **Recurring schedules** run an agent on an interval you set, with real reliability tracking — consecutive failures auto-pause a schedule rather than silently failing forever, and a one-click "Test" run lets you inspect a schedule's behavior without affecting its reliability stats or next-run timer.
- Optional **proactive decision mode**: a scheduled agent can decide for itself, per run, whether something is actually worth notifying you about — with deduplication so the same recurring condition doesn't page you every single run, and configurable quiet hours.
- **Webhooks** trigger any agent from an external system via a secret-protected URL, with brute-force lockout protection built in.
- **Telegram**: connect any number of independent bots, each pointed at its own agent with its own trusted-sender list — one bot per purpose, fully isolated from each other. Works in simple polling mode (no public URL needed) or webhook mode for always-on setups.
- **Notifications** reach you two independent ways — browser push (even when no JunctionBox tab is open) and in-app popups — configurable per agent and per event type (run finished, needs input, needs approval, and more).

## Tools, MCP, and the plugin architecture

- Full **MCP (Model Context Protocol)** support: browse a built-in tool catalog or search the public MCP Registry, and install a new tool in a couple of clicks.
- Tools are discovered **on demand** rather than front-loaded into every request — an agent that never needs a tool pays nothing for the ones sitting installed and idle, so adding more tools never makes every other run slower or more expensive.
- A private, on-box **search engine** is set up automatically on install — genuinely free, no API key, no account, and reachable only from your own agents.
- An open **plugin architecture** lets you extend JunctionBox with entirely new capabilities: your own backend routes, your own UI page (rendered in a sandboxed frame so a plugin's frontend can never read JunctionBox's session or the rest of the page), and your own MCP tools exposed to agents. Install a plugin as a single package — no approval queue, no waiting on anyone.
- A **Plugin Builder** comes pre-installed from your very first launch: describe the plugin you want (an id, a name, a description) and it scaffolds a ready-to-install package — manifest, backend route stub, and a themed frontend stub — as a starting point for your own.
- **Kubernetes** comes built in: register this machine or any remote machine over SSH as a Host, then create and manage disposable `kind` clusters — full lifecycle (create/start/stop/destroy/recreate) plus day-2 inspection of namespaces, pods, deployments, services, logs, and Helm releases. An extensible Cluster Plugins layer lets you register your own reusable `kubectl`/binary commands with typed parameters.
- **iCloud Mail Cleanup** comes built in: connect an iCloud Mail account (an Apple app-specific password, never your Apple ID password) to declutter an inbox — sender-grouped scanning, manual trash/archive/unsubscribe, optional AI-assisted junk classification, and a guardrail-bounded automatic cleanup mode with per-run/per-day action caps and a protect-list, so an automated pass can never do more than the same buttons you'd click yourself.
- **Dev Tools** gives every agent a `run_command` tool for tests, builds, and linters, scoped to that agent's own existing sandbox (no broader access than it already has running its CLI directly) — deliberately without an approval gate, since nothing it does ever leaves that sandbox.
- The architecture is also proven against substantial personal-use integrations not bundled with JunctionBox core — guardrailed autonomous stock trading with hard position/ticker limits, multi-protocol smart-home control, AI image/video generation pipelines with identity-preserving face conditioning, and more — showing what a plugin here is actually capable of beyond what ships by default.

## Reliability you can trust with long-running work

- Runs are **durable** — queued and executed by a background daemon, tracked in a database rather than held together by an open browser tab. A run survives a page refresh, a closed browser, or even a full server restart.
- Optional **checkpointing**: a long-running agent can save its progress, completed/remaining steps, and exact resume instructions — then be resumed later with the same agent or handed to a different one entirely.
- Optional **stall detection** watches for runs that have genuinely stopped making progress (not just gone quiet) and surfaces them for you to cancel, retry, or resume from the last checkpoint — without ever restarting the whole system to recover one stuck run.
- Configurable **token and cost budgets** per run, broken down by exactly where the tokens are going (system prompt, conversation history, memory, tool schemas, and more), with a hard stop that checkpoints first so a runaway run never just loses its work.
- Optional **context compaction** keeps long conversations affordable automatically — older turns get summarized while recent turns and your explicit corrections are kept verbatim, large command output and failing-test logs are trimmed to what matters, and unchanged files aren't resent in full.

## Machines ("Boxes") and remote execution

- Register any machine you control by SSH, with a guided setup flow (key generation, permission fixes, verified key-only login) that works for both Linux and macOS targets.
- Two distinct ways to use a registered machine: give an agent its connection details so it can decide to SSH there itself, or actually **run the agent's own process on that machine** — its filesystem and shell tools then genuinely operate there, not through a mounted view.
- A **Passthrough mode** for remote execution strips out everything JunctionBox-specific (safety baseline, delegation wiring, memory injection) so a remote agent runs with nothing but its own prompt and the CLI's native tools — useful when you want zero footprint beyond the agent itself.
- Full interactive terminal access to any registered machine, local or remote, directly inside a chat tab.

## Security and privacy by design

- **Local-first**: your agent conversations, credentials, and run history are stored in a local database on your own machine, not transmitted anywhere by default.
- Every local CLI agent runs inside an OS-level sandbox on top of its own native permission system — a compromised or misled agent is contained by the operating system, not just asked nicely.
- **System Operations**: an agent can be granted time-boxed "privileged mode" to *propose* a system-level script (installing software, etc.), but nothing ever executes from the proposal itself — a human reviews the literal script text and explicitly approves or denies it before anything runs.
- **Agent Swap Groups** let a specifically authorized agent trigger a GPU/resource handoff mid-conversation — authorization is fail-closed: an agent can trigger nothing until a human has explicitly granted it access to that specific resource.
- Password-protected access with secure session cookies, CSRF protection, automatic lockout after repeated failed logins, and a complete audit log of every change made through the system.
- API keys, SSH credentials, and other secrets are encrypted at rest, never shown back in full once saved.

## Observability

- A **Dashboard** summarizing agents, providers, tools, and recent activity, with seven-day run/token trend charts.
- Full **run history** with search, status filtering, token counts, and estimated cost — click any past run to reopen and continue that exact conversation.
- **Evaluations**: run one prompt across several agents at once and score the results against an expected answer, to see which setup actually performs best.

## Licensing

- **Free**: up to 2 active agents, no account or payment required — you can still save as many agent configurations as you like.
- **JunctionBox Pro** ($49/year): unlimited active agents. Upgrade and manage your subscription entirely through a Stripe-hosted checkout and billing portal — JunctionBox itself never sees your payment details.
- Licensing is verified against a cryptographically signed token, not a value that can simply be edited locally, and it fails closed: anything that doesn't check out resolves to Free, never Pro.
- Works offline too: once activated, Pro stays active for up to 14 days without needing to reach the license server, refreshing automatically in the background the rest of the time.

---

For installation steps, see the Install Guide. For day-to-day usage, see the User & Admin Guide.
