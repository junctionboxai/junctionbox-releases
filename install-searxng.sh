#!/usr/bin/env bash
# Installs JunctionBox's private, on-box search engine (SearXNG) and registers
# it as an MCP server so agents can search the web on demand -- no third-party
# API key, no per-query billing, and nothing reaches the internet under
# anyone's identity but this machine's, since the instance never listens on
# anything but 127.0.0.1. Idempotent: safe to re-run.
set -e

DEPLOY_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$DEPLOY_DIR/.." && pwd)"
SEARXNG_DIR="$HOME/.junctionbox/searxng"
OS="$(uname -s)"
SEARXNG_PORT=8888

echo "Installing JunctionBox private search (SearXNG)..."

# ── System packages (lxml build deps + venv module) ─────────────────────────
if [ "$OS" = "Darwin" ]; then
    # python3-venv has no macOS equivalent -- venv ships in the standard
    # library on every Python 3 install there, no separate package needed.
    if command -v brew >/dev/null 2>&1; then
        MISSING_PKGS=()
        for pkg in libxml2 libxslt; do
            brew list "$pkg" >/dev/null 2>&1 || MISSING_PKGS+=("$pkg")
        done
        if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
            echo "Installing required packages via Homebrew: ${MISSING_PKGS[*]}"
            brew install "${MISSING_PKGS[@]}"
        fi
    else
        echo "Homebrew not found -- skipping libxml2/libxslt install. If the pip install"
        echo "step below fails to build lxml, install Homebrew (https://brew.sh) and"
        echo "run 'brew install libxml2 libxslt', then re-run this script."
    fi
else
    MISSING_PKGS=()
    for pkg in libxml2-dev libxslt1-dev python3-venv; do
        dpkg -l "$pkg" >/dev/null 2>&1 || MISSING_PKGS+=("$pkg")
    done
    if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
        echo "Installing required system packages: ${MISSING_PKGS[*]}"
        sudo apt-get install -y "${MISSING_PKGS[@]}"
    fi
fi

mkdir -p "$SEARXNG_DIR"

# ── Source ────────────────────────────────────────────────────────────────
if [ ! -d "$SEARXNG_DIR/searxng-src" ]; then
    git clone --depth 1 https://github.com/searxng/searxng.git "$SEARXNG_DIR/searxng-src"
else
    echo "SearXNG source already present, skipping clone."
fi

# ── Dedicated venv (kept isolated from JunctionBox's own backend deps) ─────────
if [ ! -d "$SEARXNG_DIR/venv" ]; then
    python3 -m venv "$SEARXNG_DIR/venv"
fi
"$SEARXNG_DIR/venv/bin/pip" install -U pip setuptools wheel -q
"$SEARXNG_DIR/venv/bin/pip" install -r "$SEARXNG_DIR/searxng-src/requirements.txt" -q
# --no-build-isolation: SearXNG's setup.py imports msgspec at build time, so
# it must already be present in this environment rather than an isolated one.
"$SEARXNG_DIR/venv/bin/pip" install -e "$SEARXNG_DIR/searxng-src" --no-deps --no-build-isolation -q
"$SEARXNG_DIR/venv/bin/pip" install gunicorn -q

# ── Config: private-only bind (already the upstream default) + JSON output
# (off by default upstream since it's meant for public instances where an
# open JSON API is an abuse vector -- irrelevant here, nothing but this
# machine's own agents can ever reach this instance) ────────────────────────
if [ ! -f "$SEARXNG_DIR/settings.yml" ]; then
    cp "$SEARXNG_DIR/searxng-src/searx/settings.yml" "$SEARXNG_DIR/settings.yml"
    python3 - "$SEARXNG_DIR/settings.yml" <<'PYEOF'
import sys
path = sys.argv[1]
with open(path) as f:
    content = f.read()
content = content.replace("  formats:\n    - html", "  formats:\n    - html\n    - json")
with open(path, "w") as f:
    f.write(content)
PYEOF
fi

if [ ! -f "$SEARXNG_DIR/secret.key" ]; then
    python3 -c "import secrets; print(secrets.token_hex(32))" > "$SEARXNG_DIR/secret.key"
    chmod 600 "$SEARXNG_DIR/secret.key"
fi

# ── Launcher ──────────────────────────────────────────────────────────────
cat > "$SEARXNG_DIR/run.sh" <<EOF
#!/bin/bash
# JunctionBox-managed SearXNG launcher -- private, localhost-only instance used
# by JunctionBox's on-demand search MCP tool. Not a public-facing service.
set -e
cd "$SEARXNG_DIR/searxng-src"
export SEARXNG_SECRET="\$(cat "$SEARXNG_DIR/secret.key")"
export SEARXNG_SETTINGS_PATH="$SEARXNG_DIR/settings.yml"
exec "$SEARXNG_DIR/venv/bin/gunicorn" \\
    --bind 127.0.0.1:$SEARXNG_PORT \\
    --workers 2 \\
    --timeout 30 \\
    searx.webapp:app
EOF
chmod +x "$SEARXNG_DIR/run.sh"

# ── Background service: systemd --user on Linux, a launchd user agent on
# macOS (systemd doesn't exist there) ───────────────────────────────────────
if [ "$OS" = "Darwin" ]; then
    LABEL="com.junctionbox.junctionbox-searxng"
    LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
    mkdir -p "$LAUNCH_AGENTS_DIR"
    PLIST="$LAUNCH_AGENTS_DIR/$LABEL.plist"
    cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SEARXNG_DIR/run.sh</string>
    </array>
    <key>WorkingDirectory</key>
    <string>$SEARXNG_DIR</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>ProcessType</key>
    <string>Background</string>
    <key>StandardOutPath</key>
    <string>$HOME/.junctionbox/logs/junctionbox-searxng.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/.junctionbox/logs/junctionbox-searxng.log</string>
</dict>
</plist>
EOF
    mkdir -p "$HOME/.junctionbox/logs"
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$PLIST"
else
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_DIR"
    cat > "$SYSTEMD_DIR/junctionbox-searxng.service" <<EOF
[Unit]
Description=JunctionBox Private Search (SearXNG)
After=network.target

[Service]
Type=simple
WorkingDirectory=$SEARXNG_DIR
ExecStart=$SEARXNG_DIR/run.sh
Restart=on-failure
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF
    systemctl --user daemon-reload
    systemctl --user enable --now junctionbox-searxng.service
fi

echo "Waiting for SearXNG to come up..."
for i in $(seq 1 15); do
    if curl -sf "http://127.0.0.1:$SEARXNG_PORT/search?q=test&format=json" >/dev/null 2>&1; then
        echo "SearXNG is up on 127.0.0.1:$SEARXNG_PORT"
        break
    fi
    sleep 1
done

# ── MCP server registration (idempotent) ─────────────────────────────────
# Uses the backend's own Python environment, matching how the app itself
# runs -- this is not a standalone script, it needs app.db/app.secrets.
cd "$REPO_DIR/backend"
python3 - <<PYEOF
from app import db
db.init_db()
import uuid, json
from app.secrets import encrypt_secret
with db.get_db() as conn:
    existing = conn.execute("SELECT id FROM mcp_servers WHERE name='SearXNG'").fetchone()
    if existing:
        print("SearXNG MCP server already registered:", existing["id"])
    else:
        server_id = uuid.uuid4().hex[:12]
        conn.execute(
            "INSERT INTO mcp_servers (id, name, command, env) VALUES (?, ?, ?, ?)",
            (server_id, "SearXNG", "npx -y mcp-searxng",
             encrypt_secret(json.dumps({"SEARXNG_URL": "http://127.0.0.1:$SEARXNG_PORT"}))),
        )
        conn.commit()
        print("Registered SearXNG MCP server:", server_id)
PYEOF

echo "JunctionBox private search installed and running."
if [ "$OS" = "Darwin" ]; then
    echo "  Logs: tail -f $HOME/.junctionbox/logs/junctionbox-searxng.log"
    echo "  Restart: launchctl kickstart -k gui/\$(id -u)/com.junctionbox.junctionbox-searxng"
else
    echo "  Logs: journalctl --user -u junctionbox-searxng -f"
    echo "  Restart: systemctl --user restart junctionbox-searxng"
fi
