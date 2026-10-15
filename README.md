# JunctionBox

A local-first AI agent orchestration platform: everything (the database,
your credentials, agent runs) stays on this machine unless you choose to
expose it.

This repo hosts **downloads and documentation only** — no source code.
Pre-built, self-contained binaries are attached to each
[Release](../../releases/latest); no Python, Node, or any other runtime
needs to be installed first.

## Download

Go to the [latest release](../../releases/latest) and download the
archive for your platform (e.g. `junctionbox-<version>-linux-x86_64.tar.gz`
or the macOS equivalent), then extract it:

```bash
tar -xzf junctionbox-*-*.tar.gz
cd junctionbox-release
```

## What's in a release

| File | What it is |
|---|---|
| `junctionbox-api` | The web API and UI server (frozen executable) |
| `junctionboxd` | The background agent daemon that runs queued/scheduled agent work |
| `frontend-dist/` | The built web UI, served by `junctionbox-api` |
| `install-services.sh` | Installs and starts both as a background service (systemd `--user` on Linux, launchd user agents on macOS) |
| `uninstall-services.sh` | Stops and removes them |
| `install-searxng.sh` | Optional: sets up a private, on-box search engine for agents |
| `junctionbox-api.service`, `junctionboxd.service` | The systemd unit files `install-services.sh` installs on Linux |
| `com.junctionbox.junctionbox-api.plist`, `com.junctionbox.junctionboxd.plist` | The launchd agent files `install-services.sh` installs on macOS |
| `*.zip` (attached separately) | Optional plugins — see [`docs/PLUGINS.md`](docs/PLUGINS.md) |

The full documentation set is also kept here in [`docs/`](docs/), and ships
alongside the binaries in every release archive:

- [`docs/USER_GUIDE.md`](docs/USER_GUIDE.md) — day-to-day use: agents, chat, delegation, scheduling, memory, administration
- [`docs/FEATURES.md`](docs/FEATURES.md) — what JunctionBox can do, at a glance
- [`docs/PLUGINS.md`](docs/PLUGINS.md) — optional plugins you can install
- [`docs/JUNCTIONBOX_PLUGIN_CONTEXT.md`](docs/JUNCTIONBOX_PLUGIN_CONTEXT.md) — the plugin format, for writing your own
- [`docs/DEPLOYMENT_SECURITY.md`](docs/DEPLOYMENT_SECURITY.md) — how to safely expose JunctionBox beyond `127.0.0.1`
- [`docs/EULA.md`](docs/EULA.md) — the license terms you agree to by installing JunctionBox
- [`docs/PRIVACY_POLICY.md`](docs/PRIVACY_POLICY.md) — what JunctionBox Pro licensing collects, and what it never collects
- [`docs/THIRD_PARTY_NOTICES.md`](docs/THIRD_PARTY_NOTICES.md) — open-source components bundled with JunctionBox and their licenses

Installing or using JunctionBox means you agree to the terms in `docs/EULA.md` and `docs/PRIVACY_POLICY.md`.

## Prerequisites

**Linux:**
- systemd, with a **user** (not system) instance available
  (`systemctl --user status` should not error). This is the default on
  virtually every desktop Linux distro.
- `loginctl enable-linger` support, so the services keep running after you
  log out (the installer does this automatically).

**macOS:**
- Nothing beyond the OS itself — `launchd` (macOS's own service manager)
  ships on every Mac. Services install as per-user LaunchAgents: they start
  automatically when you log in and keep running while you're logged in,
  the same way most macOS menu-bar/background apps work. Unlike Linux's
  `loginctl enable-linger`, there's no way to keep a LaunchAgent running
  through a full logout — that would require a system-level LaunchDaemon
  instead (a different install with different permissions, not what this
  installer sets up).

Windows is not supported by this installer yet.

## Install

```bash
./install-services.sh
```

This copies `junctionbox-api` and `junctionboxd` into `~/.junctionbox/bin/`,
the built UI into `~/.junctionbox/frontend-dist/`, installs both as
background services (systemd units on Linux, LaunchAgents on macOS),
enables them to start on login, and starts them immediately. It also
attempts to set up a private local search engine (SearXNG) for agents —
if that step fails (e.g. no network at install time), everything else still
works; agents just won't have a web search tool until you re-run
`install-searxng.sh` later.

## First-time setup

Open **http://127.0.0.1:8000** in a browser on this same machine. You'll be
asked to set a password on first visit — this is required before any agent,
credential, or setting can be created. Setup can only be completed from the
JunctionBox host itself (not over a network), and every route stays locked
until it's done.

## Licensing: Free vs. Pro

JunctionBox runs on the **Free** tier by default — no account, no payment, no network call required. Free allows up to **2 active agents** at a time; you can save as many agent configurations as you like, but only 2 can be enabled (running) at once. A 3rd agent you create is saved but starts disabled, and trying to enable it shows an upgrade prompt rather than failing silently.

**JunctionBox Pro** ($49/year) removes that limit entirely. To upgrade:

1. In Settings → License, click **Upgrade to Pro** (opens a Stripe-hosted checkout page — no payment info is ever seen by JunctionBox itself).
2. After payment, you'll land on a page showing a one-time **activation code**. Copy it.
3. Back in JunctionBox, paste the code into Settings → License → **Activate Pro**.

Your subscription auto-renews yearly by default. **Manage Subscription** (Settings → License, Pro only) opens a Stripe-hosted billing portal where you can update your payment method or cancel — canceling keeps Pro access through the period you already paid for, then reverts to Free automatically; it doesn't cut you off immediately. **Deactivate This Device** frees your license's device slot immediately (each license is bound to one device at a time) if you're moving to a new machine — deactivate on the old one before activating on the new one.

See [`docs/PRIVACY_POLICY.md`](docs/PRIVACY_POLICY.md) for exactly what licensing/billing information this involves.

## Managing the service

**Linux:**
```bash
systemctl --user status junctionbox-api junctionboxd     # is it running?
systemctl --user restart junctionbox-api junctionboxd    # apply a config change
journalctl --user -u junctionbox-api -f                # follow the API log
journalctl --user -u junctionboxd -f                   # follow the agent daemon log
```

**macOS:**
```bash
launchctl list com.junctionbox.junctionbox-api                       # is it running? (a PID means yes)
launchctl kickstart -k gui/$(id -u)/com.junctionbox.junctionbox-api  # apply a config change
tail -f ~/.junctionbox/logs/junctionbox-api.log                       # follow the API log
tail -f ~/.junctionbox/logs/junctionboxd.log                          # follow the agent daemon log
```

## Where your data lives

Everything JunctionBox stores — the SQLite database, encrypted credentials,
job/run history, and any plugins you install — lives under
`~/.junctionbox/`. Nothing under the release folder you extracted is ever
written to after install; you can delete it once `install-services.sh` has
run and JunctionBox will keep working.

## Exposing JunctionBox beyond this machine

By default JunctionBox only listens on `127.0.0.1` — nothing outside this
machine can reach it. To access it from another device (put it behind
HTTPS, share it with a team, etc.), see
[`docs/DEPLOYMENT_SECURITY.md`](docs/DEPLOYMENT_SECURITY.md) before
changing `JUNCTIONBOX_API_HOST`.

## Installing plugins

Settings → Plugins → "Browse for plugin ZIP", then restart JunctionBox
(`systemctl --user restart junctionbox-api` on Linux, or
`launchctl kickstart -k gui/$(id -u)/com.junctionbox.junctionbox-api` on
macOS) for a newly installed plugin's routes to mount. See
[`docs/JUNCTIONBOX_PLUGIN_CONTEXT.md`](docs/JUNCTIONBOX_PLUGIN_CONTEXT.md)
for how to build your own — plugins are self-service; there's no
marketplace or review step.

## Uninstalling

```bash
./uninstall-services.sh
```

Stops and removes the services. By default this **keeps** your data at
`~/.junctionbox/` (database, credentials, job history, plugins) so a
reinstall picks up right where you left off — you'll be asked whether to
also delete it, or pass `--purge-data` to skip the prompt and wipe
everything in one step.

## Troubleshooting

**Linux:**
- **"Address already in use" / port 8000 taken**: something else on this
  machine is using port 8000. Edit `JUNCTIONBOX_API_PORT` in
  `~/.config/systemd/user/junctionbox-api.service`, then
  `systemctl --user daemon-reload && systemctl --user restart junctionbox-api`.
- **Services don't survive logout**: `loginctl enable-linger $(whoami)`
  (the installer tries this automatically, but it can silently fail
  depending on your distro's polkit configuration).
- **Nothing loads at `http://127.0.0.1:8000`**: check
  `journalctl --user -u junctionbox-api -e` for the actual error.

**macOS:**
- **"Address already in use" / port 8000 taken**: edit the
  `JUNCTIONBOX_API_PORT` entry in
  `~/Library/LaunchAgents/com.junctionbox.junctionbox-api.plist`, then
  `launchctl bootout gui/$(id -u)/com.junctionbox.junctionbox-api && launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.junctionbox.junctionbox-api.plist`.
- **Nothing loads at `http://127.0.0.1:8000`**: check
  `~/.junctionbox/logs/junctionbox-api.log` for the actual error.
- **Service stopped after I logged out and back in**: LaunchAgents restart
  automatically at login (`RunAtLoad`), so this should self-heal — if it
  didn't, run `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.junctionbox.junctionbox-api.plist` manually.
