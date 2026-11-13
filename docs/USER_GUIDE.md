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
- [Smart TV Launcher: your TVs (Roku, Google TV and Fire TV)](#smart-tv-launcher-your-tvs-roku-google-tv-and-fire-tv)
- [Licensing: Free vs. Pro](#licensing-free-vs-pro)
- [Administration](#administration)
- [Troubleshooting](#troubleshooting)

## Getting started

1. Install JunctionBox per `deploy/README-release.md` (Linux and macOS: `install-services.sh`; Windows: `install-services.ps1`, see *JunctionBox on Windows* below), then open `http://127.0.0.1:8000` **on that machine**.
2. On first visit you'll set an access password (8+ characters) and accept the EULA — nothing else about JunctionBox works until it's done. This also works through the HTTPS proxy below, from any device on your LAN, so set a real password promptly after install.
3. Log in with that password going forward. There's no "forgot password" flow — if you lose it, you'd need direct access to the machine to reset it (see Administration below).
4. You'll land on the **Dashboard**: a summary of agents, providers, MCP tools, and recent activity, with a 3-step getting-started checklist until your first run exists.
5. A **JunctionBox Support** agent is already there, auto-created — ask it how to use JunctionBox, or whether core services are running, at any time. It's protected (can't be deleted or have its prompt edited) and never appears as a delegation target for your other agents.

The next three sections — Providers, Agents, Chat — are the minimum to get a working agent talking to you.

### JunctionBox on Windows

JunctionBox runs natively on 64-bit Windows (built for Windows 10, 11 and Server 2019 or newer; tested on Windows Server 2022), with no WSL and no administrator rights. Everything in this guide works the same way, with these differences:

- **Install and services.** `install-services.ps1` copies the programs to `%USERPROFILE%\.junctionbox` and registers per-user **Scheduled Tasks** (`JunctionBox-junctionbox-api`, `JunctionBox-junctionboxd`, and the optional HTTPS proxy and search). They start when you log in, are restarted if they stop, and run while you are logged in (the same arrangement as the macOS LaunchAgents; they don't run through a full log out). Logs are in `%USERPROFILE%\.junctionbox\logs`. Restart a service with `Stop-ScheduledTask` then `Start-ScheduledTask`, or from the Settings restart buttons.
- **Windows Firewall.** The first time the HTTPS proxy needs the network, Windows asks whether to allow it: choose **Private networks**. (If the installer is run as an administrator it adds the rule itself, for private and domain networks only.) A network Windows has marked *Public* stays blocked.
- **No agent sandbox.** On Linux and macOS, local agents (Claude Code, Codex, Grok and every agent's `run_command`) are confined by the operating system to the folders their permission profile allows. Windows has no equivalent, so there they run with your own Windows account's rights, and JunctionBox's private files in `%USERPROFILE%\.junctionbox` are not hidden from them. The permission profile still decides what each tool is told it may do. Settings shows this note next to the profile. Prefer agents that run on a remote box, or keep high-risk work on a Linux or macOS machine, if you need real confinement.
- **Terminals.** The web terminal opens PowerShell (or the shell you have) through Windows' own console (ConPTY), and boxes still use your `ssh`, which Windows 10 and later include.
- **Local commands.** `run_command` (Dev Tools) and System Ops scripts run in PowerShell. System Ops can't ask Windows for administrator rights (there is no `sudo`), so a privileged step on this PC itself reports that it needs them.
- **Not available on the Windows computer itself:** screen sharing of that PC (add it as a box over SSH with Windows' OpenSSH Server, like any other Windows box), starting and stopping Tailscale's background service and restarting Ollama from JunctionBox (use their tray icons), and the browser-fallback plugin.
- **Optional tools** the usual way: `winget install Gyan.FFmpeg` (ffmpeg), `winget install oschwartz10612.Poppler` (PDF pages for the TV launcher). Private search (SearXNG) needs Python 3.10 or newer; the installer adds a per-user Python 3.12 if there isn't one.

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
- **Smart TV Launcher** is a plugin with its own section below.
- **A plugin runs with the same privileges as JunctionBox itself.** There's no sandbox between a plugin and your data — install one only from a source you trust, the same judgment call as installing a browser extension.

## Machines ("Boxes") and terminals

**Boxes** are machine connection records — this host (seeded automatically) or any remote machine over SSH. From Boxes you can open a real interactive terminal to any configured machine, or set up SSH access with a guided key-generation flow. An agent can be assigned to a box two different ways:

- By default, the agent is just told about the box (connection details in its prompt) and decides for itself whether to SSH there.
- **Remote execution** (`run_remote_on_box`, set per agent) actually moves the agent's own execution onto that box — its filesystem/shell tools genuinely operate there, not a local sandbox.

### Windows boxes

Windows targets work the same way, over the same SSH trust boundary, but need one manual one-time step first: Windows doesn't ship its OpenSSH **Server** turned on by default (only the client). From an elevated PowerShell prompt *on the Windows box itself* (e.g. over RDP):

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

After that, automatic setup in Boxes works exactly like Linux/macOS — pick **Windows** in the Target OS selector there, use the box's actual local-administrator account (the built-in `Administrator` account works best), and the guided flow handles the rest. This matters specifically because Windows has no `sudo`: System Operations' privileged scripts and remote agent execution both need the SSH session itself to already be elevated, which an actual local-administrator account gives you automatically — a regular user account, even one in the Administrators group, may not. Terminal works unmodified (Windows OpenSSH gives a genuine interactive PTY via ConPTY), defaulting to `cmd.exe` unless you've set the box's own `DefaultShell` registry value to PowerShell.

## Screen sharing

From a Box's card, click **Screen Share** for full mouse-and-keyboard remote control of that machine, in its own tab right alongside Chat and Terminal — not just a view, real input. This works for any registered Box, including the machine JunctionBox itself runs on ("Local").

Nothing is installed permanently on the *target* machine:

- **Linux**: a VNC server is set up fresh when you open the tab and torn down completely when you close it. Nothing is left running or installed afterward beyond the package itself (installed once, like any other apt/dnf package).
- **macOS**: no third-party software at all — it's the Mac's own built-in Screen Sharing (the same thing "Remote Management" in System Settings controls), switched on only for the session with a fresh one-time password, and switched off again when you close the tab.
- **Windows**: a VNC server (TightVNC) is installed automatically the first time you screen-share into a given box — nothing to set up by hand, on either the Windows box or the JunctionBox host. It's left installed afterward (same product decision as Linux), but only ever actually running for the life of a session, same as Linux's VNC server. Unlike Linux/macOS, this needs the target Windows account to have logged into a real session (console or RDP) at least once before Screen Share can find a desktop to attach to — if it hasn't, starting a session will tell you so directly.

A few things worth knowing:

- On a **phone or tablet**, there's no physical keyboard to type with — a keyboard icon in the screen-share tab opens a tap-to-type input.
- The **first** time you screen-share into a given Mac, macOS requires the Screen Recording permission to have been granted at least once *interactively, at that Mac itself* (System Settings → Privacy & Security → Screen Recording) — this can't be done remotely or via SSH by design (Apple's own hardening, so SSH access alone can never silently turn on remote screen viewing). If a session connects but shows a black screen, this is almost always why — go grant it once at the machine and it's a one-time fix per Mac.
- Screen sharing to the local box requires either passwordless `sudo` or a stored sudo password on that Box's own connection record (Boxes → Local → Edit) — without one of those, starting a local session will tell you so directly.

## Smart TV Launcher: your TVs (Roku, Google TV and Fire TV)

Smart TV Launcher is a plugin that puts your own home screen on your Roku TVs and boxes and on Google TV / Android TV sets: big tiles for your streaming apps, the weather, a quote, and a **JunctionBox** screen with your lights, cameras, videos, photos, books, coding-agent terminals and more. It also makes a short narrated **Morning Briefing** each day. This section is the everyday how-to; the complete reference (every card, every key, every troubleshooting message) is [`SMART_TV_LAUNCHER.md`](SMART_TV_LAUNCHER.md), and [`VISUAL_GUIDE.md`](VISUAL_GUIDE.md) has pictures of the real screens.

**Where it runs.** JunctionBox runs on Linux, macOS and Windows (and can manage Windows, Linux and macOS machines as boxes). The Smart TV Launcher's bridge runs on that same computer, and the launcher itself runs on Roku TVs and boxes, on Google TV / Android TV sets, and on Fire TV (Fire OS 7 or newer; built but not yet run on a real Fire TV).

It has two parts. The **TV app** is installed on each TV (sideloaded on a Roku in developer mode, or a small Android app on a Google TV); nothing goes through Roku's channel store. The **bridge** is a small background program on the computer that runs JunctionBox: the TV asks it for weather, pictures and your data, and it sends the TV back to the launcher when you leave an app. Nothing leaves your home network except the weather lookup and, for the Tutorials tile, one small public list of video links from junctionboxai.com (videos then play in the TV's own YouTube app).

### Setting it up

1. **Get each TV ready (once per TV).** Roku: turn on developer mode with **Home x3, Up x2, Right, Left, Right, Left, Right**, note the IP address, choose *Enable installer and restart*, and pick a webserver password. Google TV: press **Build** seven times in *Settings, System, About*, then turn on *USB debugging* and *Wireless debugging*, and open *Pair device with pairing code*. Give every TV, and the JunctionBox computer, a fixed address (a DHCP reservation in your router).
2. **Install the plugin.** *Settings, Plugins, Browse for plugin ZIP*, choose `smart-tv-launcher.zip`, and restart JunctionBox when asked. **Smart TV Launcher** appears in the sidebar.
3. **Open the plugin page** and work down its numbered cards:
   - **Card 2, the bridge:** press **Set up the bridge**. It builds its own private Python environment and registers a login service. When it says **Running**, add any optional parts you want (Ring live view, Web Video, ffmpeg, pdftoppm).
   - **Card 3, your TVs:** **Find Rokus on my network** (or type the address) with the developer password, or **Pair and add** for a Google TV. Then press **Install** on each TV, or **Install or update on all TVs**. The launcher opens on the TV right away.
   - **Card 4, the home screen:** your weather town, which apps get tiles (picked from the TV's own installed apps), and the quote line.
   - **Card 5, Bibles:** seven public-domain Bibles to build into PDFs for reading on the TV.
   - **Card 6, terminals, agents and screen share:** set the PIN that guards them (below).
   - **Card 7, JB Settings and away access.**
   - **Cards 8 to 15, the Morning Briefing** (below).
4. On a Google TV you can press **Make it the Home screen** so the Home button opens the launcher; **Restore Google Home** undoes it. A Fire TV can't have a Home screen of its own (Amazon doesn't allow it): turn on *Settings, My Fire TV, Developer options, ADB debugging*, add it with **Connect and add** (accept the prompt on the TV with *Always allow*), press **Install**, and the launcher then comes back by itself whenever Amazon's home screen shows. Google TVs and Fire TVs can also be switched on and off in **Home Control**.

### Using the launcher on the TV

- **Home:** the top row are your apps, then **Media Player** (play a video or audio address), **Web Video**, **JunctionBox** (a row of hub tiles, five at a time on a Roku) and **Settings**. Leaving an app with Back or Home returns to the launcher; to really leave, use *Settings, Exit launcher*.
- **Hub tiles**, depending on the plugins you have: **Games** (four arcade games), **Grill** (a Pit Boss grill's temperatures), **Home Control** (lights, groups, colours, air conditioning, TV remote), **Ring Security** (snapshots, live view with audio), **Video Studio** (your generated videos, remembering where you stopped; **Movie Maker** can plan, review and export a whole movie from the couch), **Photos** (Stickers, Age Shift, Storyboard, Time Machine; hidden groups never appear and password-protected groups show as locked), **Books** (Comic Studio and Book Studio PDFs and your Bibles, each remembering its page, with a contents and chapter list and study guides, and an optional **Read aloud** that reads a Bible or Book Studio book to you, turning the pages as it goes: press Options (`*`) on Roku or OK on Google TV, never on unless you choose it; add your own EPUBs and PDFs, or free Project Gutenberg books, from the plugin page and they appear under **My books**), **Recipes**, **Box Status**. Favourite teams get their own tiles with the next game and a full schedule (set up on the plugin page, card 9), and TV reminders (card 10) turn the TV on and tell you what you asked to be reminded about, aloud, until you press Done.
- **Web Video:** browse a website with the remote; when a page has a video a green **VIDEO FOUND** badge appears and **Play** hands it to the TV's own player. YouTube links open in the Roku's YouTube app. Videos you save in the **Watch List** plugin appear on its start page.
- **Terminals, Box Shells, Screen Share and Agents** are powerful, so they stay off until you set a **PIN** (4 to 12 digits) on card 6. The TV asks for it each time, five wrong tries lock it for five minutes, and a session signs out after 15 idle minutes.
  - **Claude, Codex, Grok:** a terminal for that coding agent running on the JunctionBox computer. Card 6 lets you pick how much each may do without asking. Sessions keep running when you leave the screen.
  - **Box Shells:** a shell on any box JunctionBox knows, using the credentials JunctionBox already holds; nothing is stored on the TV.
  - **Screen Share:** a box's screen on the TV, driven with the remote's pointer; it needs the Web Video part.
  - **Agents:** chat with your JunctionBox agents, with the same permissions, sandbox and history as in the web app. Tool approvals and questions appear on the TV, and pop-ups go only to the TV that started the chat.
- **JB Settings** (PIN) shows GPU services, machine credentials (write-only), system health and **Away access**, which publishes only the launcher bridge through Tailscale Funnel so a TV on another network can still use it.

### Android tablet launcher

The plugin also contains a launcher for an **Android tablet** (Android 8 or newer). It is a small app, `tablet.apk` (package `com.junctionbox.tablet`), that shows the bridge's touch pages full screen and can be the tablet's Home screen. The pages come from your computer, so new features appear without reinstalling the app, and the same bridge and key are used as for the TVs.

- **Home:** your apps as icons (with favorites you choose) and the JunctionBox plugins you pin. A battery and network indicator is shown, and the app can float as a small picture-in-picture window.
- **Screens:** **Agents** (chat with your JunctionBox agents), **Home Control**, **Recipes**, **Reminders**, **Cameras** (Ring), **Terminal** and **Screen Share**. Agents, Terminal and Screen Share use the same PIN as on the TVs (card 6); one PIN unlocks all three.
- **Away from home:** it tries the other addresses JunctionBox publishes (Tailscale Funnel, card 7) when your home address can't be reached.
- **Setting it up (by hand for now; the plugin page has no install button for tablets):**
  1. On the tablet turn on *Developer options* and *Wireless debugging* (or connect USB debugging), and connect from your computer with `adb`.
  2. Install the app, which is in the plugin's folder (`~/.junctionbox/plugins/smart-tv-launcher/launcher/android-tablet/tablet.apk`): `adb install tablet.apk`.
  3. Give it the bridge address and key once: `adb shell am start -n com.junctionbox.tablet/.MainActivity --es bridge http://YOUR-COMPUTER:PORT --es token KEY`. The address is your computer's address on the home network and the bridge's port (8791 unless you changed it, in which case it is in the file named `port` in the bridge's data folder), and the key is the file named `token` in that same folder (`~/.roku-launcher` on Linux and macOS).
  4. Press Home on the tablet and choose JunctionBox as the Home app if you want it to be the Home screen.
- **Building the app yourself:** `launcher/android-tablet/build_apk.sh` builds it with the Android SDK command-line tools. The signing key is kept outside the plugin (`~/.junctionbox/tablet-launcher-android.keystore`); keep it, because a tablet only accepts an update signed with the same key.
- **Files:** the app is in `launcher/android-tablet/` (`src/.../MainActivity.java`), the touch pages are in `launcher/bridge/tablet/` (`index.html`, `core.js`, `home.js`, `agents.js`, `hc.js`, `recipes.js`, `reminders.js`, `cameras.js`, `terminal.js`, `share.js`, `unlock.js`), and the bridge serves them at `/tablet/` and keeps each tablet's favorites and pinned plugins (`/tablet/favorites`, `/tablet/pinned_plugins`).

### Picture views for Ring cameras

During a Ring live view on a Roku, press **Play/Pause** to cycle through picture views: Normal, Night green, Night red, Low light, Contrast, Heat map, Edges, Motion map and Motion trails. They enhance or recolour what the camera sends (they are not real infrared or thermal vision), and the choice is remembered for that camera.

### Tutorials

The **Tutorials** tile (Roku, Google TV and Fire TV) lists the JunctionBox AI video tutorials. Press OK on one and it plays in the TV's YouTube app. On the web console, **Video tutorials** in the left menu and a link on the Dashboard's Getting started card open the tutorials page on junctionboxai.com.

### Games

The **Games** tile on the JunctionBox screen opens one row of four original games, free for everyone and made for the Roku:

- **Tap Takeover**: a maze chase. You are a pint glass collecting bubbles while four bottle caps hunt you; power pours turn the tables.
- **Stack Attack**: falling blocks, with a hold slot, a three-piece preview, combos and a choice of starting level.
- **Pacific Fury**: air combat over six missions with a boss at the end of each. Your aircraft fires by itself; OK drops a bomb and \* changes weapon.
- **Junction John: The Lost Circuits**: a story platformer in six worlds. Pick **New Game** to start the story, **Continue** to carry on, and **Cinematics** to watch any scene you have unlocked again. Warp conduits and the Fuse Vault lead to hidden stages, and each world ends in a boss.

Each game has its own menu with High Scores, Settings and How to Play. The top ten for each game is shared by every TV in your house and kept on your computer. The cinematics are 35 short narrated films that come with the game: the opening, each world's intro and finale, and the boss scenes. They stream from your computer to the TV. If a film can't play, the scene shows as a story card instead. Back leaves a game.

### The grill

With the **Pit Boss Grill** plugin set up (Plugins, Pit Boss Grill, then add your grill), a **Grill** tile on the TV shows the grill and probe temperatures, what the grill is doing and any error, refreshed every few seconds. In the plugin you can also switch on alerts for each grill: the TVs wake, show it full screen and say it out loud when the grill reaches its temperature, a probe reaches its target, or the grill reports a problem such as being out of pellets.

### The Morning Briefing

A narrated program, about 10 minutes by default (3 to 20 allowed), made fresh every morning on the JunctionBox computer from **your** weather, calendar, news, a scripture reading and the markets. It needs no graphics card, has no payment gating, and nothing is made until you turn it on.

**Turn it on and set it up (cards 8 to 15):**

- **Card 8:** the master switch, the time to start making it (it takes up to about half an hour, so set it well before you wake), how many times to retry if a run fails, the length, and how many days to keep. **Make today's now** builds one immediately, **Stop** cancels, and **Read today's script** shows exactly what will be said. A computer that was off at the set time catches up when it starts.
- **Card 9, what is in it:** weather and alerts, your calendar, the news, scripture and markets, each on or off, in your order, with a share of the time. A part with nothing to say is skipped, and a severe weather alert moves to the front.
- **Card 10, the news:** topics to search for (several phrases can be joined with **|**, with an optional story limit), subjects to leave out, and **What matters most**, a short instruction about what to cover first (for example your own state's election results ahead of everything else). A JunctionBox agent you choose writes short summaries; without one the headlines are read as published. If the local search is throttled it falls back to Google News. Outlets are named at the end.
- **Card 11, scripture:** a Psalm and a Proverb by the day of the month, a book read a little each day, one passage you choose, or daily readings from a table you supply. It reads at whole verses and announces the reference the way a person would ("Proverbs chapter 4, verses 1 through 5").
- **Card 12, your calendar:** add each Google Calendar with its **secret address in iCal format**. The address is stored on this computer in an owner-only file, never shown again, and calendars appear by name; private events are read as "Private event". **Test the calendars** reads each once.
- **Card 13, markets:** index and commodity figures from a best-effort public feed (or a free Finnhub key) and Treasury yields from the US Treasury, each with its date. It never gives advice.
- **Card 14, voice and pictures:** the narrator is Kokoro, running on the processor. Press **Install the voice** once (a download) and pick the voice and speed; without it a plainer fallback voice or silent captions are used. Backgrounds are slow loops of the starter clips that come with the plugin, or your own, including clips made in Video Studio. **ffmpeg** must be installed on the computer.
- **Card 15, on the TVs:** whether TVs play it by themselves, which ones are left out, and the hour after which they don't.

**Watching it:**

- The first time each TV is turned on each day (before the cut-off hour, and within 15 minutes of turning on), a Roku starts the briefing by itself, straight into the program rather than a menu. A Google TV starts it the first time its home screen shows that day. **Back** skips it. Each TV does this once a day.
- To watch it again, use the **Good morning, Wednesday, Nov 4** heading at the top of the home screen. On a Roku press **Up** from the tiles, then **OK** (**Right** moves to the weather, **Down** or **Back** returns to the tiles). On a Google TV it is the banner at the top. It has no tile of its own.
- The briefing page shows the day's picture, its length and its parts. **OK** plays, or start at any part. While it plays: **OK** pauses, **Left / Right** go back and forward 10 seconds, **Up / Down** jump parts, **Back** skips. **Sources and notes** lists where everything came from and anything left out, **Earlier briefings** shows the last week, and **Make a fresh one now** rebuilds today's.

Nothing is installed on the TVs each morning: the video is made on the computer and streamed to the TV from it. The computer and the bridge must be on when the TV is turned on.

### Updating, removing and fixing

- **Update:** install a newer `smart-tv-launcher.zip`, restart JunctionBox, then press **Update the bridge** (if offered) and **Update** on each TV.
- **Remove a TV:** **Remove** on its row; you're asked whether to delete the app from the TV too. To remove everything, remove the TVs, press **Stop** on the bridge, delete the plugin, and delete `~/.roku-launcher`.
- **Common problems:** "Can't reach a Roku" means it is in standby, on another (guest) network, or the address changed. "Developer mode is off" means repeat the Roku key sequence (a factory reset clears it). A Google TV pairing code expires in a minute or two: open *Pair device with pairing code* again. The TV app can't reach the bridge when the computer has several network connections: set the address in card 4's *Advanced* and press **Install** again. A terminal that says "The terminal is off" needs a PIN on card 6. No briefing video on a TV means the briefing isn't ready yet (check card 8) or the TV is excluded in card 15. The bridge's log is `~/.roku-launcher/bridge.log` (**Show log** on the page). See `SMART_TV_LAUNCHER.md` for the full table.

### Privacy and safety

The bridge listens on your home network only and every request needs a private token; media links are signed and short-lived. The Roku developer password is stored encrypted and used only to install on your own TVs. Calendar addresses and market keys are credentials kept in owner-only files and never shown again. Terminals, shells, Screen Share and Agents can act on your computer, so use them only on a network you trust: anyone who knows the PIN and can reach the bridge gets the access you have at that computer.

## Licensing: Free vs. Pro

- **Free**: up to 2 active agents, no account or payment needed, works fully offline.
- **Pro** ($49/yr): unlimited active agents, the Claude, Codex and Grok, agents, terminals and screen-sharing screens on your TVs, and these plugins: Ring Security, Home Control, iMessage Chat, iCloud Mail Cleanup, Slack Desktop, Kubernetes, DeviceLab, Video Studio, Book Studio, Comic Studio and Historical Intelligence. Every install gets a 7-day trial of all of it. After the trial those plugins show an upgrade card (your settings and data are kept) and unlock again with a license. The other plugins, the TV games, the tutorials, recipes, the watch list, the browsers, the image tools and the Morning Briefing stay free.

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
