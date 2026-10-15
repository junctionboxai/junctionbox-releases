#!/usr/bin/env bash
# Install a built JunctionBox release (deploy/build-release.sh's output)
# as a background service -- systemd --user on Linux, launchd user agents
# on macOS (systemd doesn't exist there at all). No python3/node/pip
# prerequisite checks needed -- that's the actual payoff of freezing
# junctionbox-api/junctionboxd into self-contained binaries; nothing here needs
# anything but the OS's own service manager.
set -e

DEPLOY_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.junctionbox"
OS="$(uname -s)"

for bin in junctionbox-api junctionboxd; do
    if [ ! -x "$DEPLOY_DIR/$bin" ]; then
        echo "error: $DEPLOY_DIR/$bin not found or not executable -- run deploy/build-release.sh first, then run this script from inside its output directory." >&2
        exit 1
    fi
done
if [ ! -f "$DEPLOY_DIR/frontend-dist/index.html" ]; then
    echo "error: $DEPLOY_DIR/frontend-dist/index.html not found -- run deploy/build-release.sh first." >&2
    exit 1
fi

echo "Installing to $INSTALL_DIR ..."
mkdir -p "$INSTALL_DIR/bin" "$INSTALL_DIR/logs"
cp "$DEPLOY_DIR/junctionbox-api" "$INSTALL_DIR/bin/"
cp "$DEPLOY_DIR/junctionboxd" "$INSTALL_DIR/bin/"
rm -rf "$INSTALL_DIR/frontend-dist"
cp -r "$DEPLOY_DIR/frontend-dist" "$INSTALL_DIR/frontend-dist"

if [ "$OS" = "Darwin" ]; then
    LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
    mkdir -p "$LAUNCH_AGENTS_DIR"
    for label in com.junctionbox.junctionbox-api com.junctionbox.junctionboxd; do
        template="$DEPLOY_DIR/$label.plist"
        if [ ! -f "$template" ]; then
            echo "error: $template not found -- was this release built with deploy/build-release.sh?" >&2
            exit 1
        fi
        plist="$LAUNCH_AGENTS_DIR/$label.plist"
        sed "s|__HOME__|$HOME|g" "$template" > "$plist"
        # Idempotent re-install: unload first if already loaded from a
        # previous install, ignore errors if it wasn't.
        launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
        launchctl bootstrap "gui/$(id -u)" "$plist"
    done

    echo "Installed and started."
    echo "  Open: http://127.0.0.1:8000"
    echo "  Logs: tail -f $INSTALL_DIR/logs/junctionbox-api.log"
    echo "        tail -f $INSTALL_DIR/logs/junctionboxd.log"
    echo "  Restart: launchctl kickstart -k gui/\$(id -u)/com.junctionbox.junctionbox-api"
    echo "  To expose beyond localhost, edit the EnvironmentVariables in"
    echo "  $LAUNCH_AGENTS_DIR/com.junctionbox.junctionbox-api.plist, then re-run this script."
    echo "  Note: these are per-user LaunchAgents -- they start automatically when you log"
    echo "  in and keep running while you're logged in, same as most macOS menu-bar-style"
    echo "  background apps. They do not persist through a full logout the way Linux's"
    echo "  loginctl enable-linger keeps a --user systemd service running headless."
    echo "  Uninstall: $DEPLOY_DIR/uninstall-services.sh"
else
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_DIR"
    cp "$DEPLOY_DIR/junctionbox-api.service" "$SYSTEMD_DIR/"
    cp "$DEPLOY_DIR/junctionboxd.service" "$SYSTEMD_DIR/"

    systemctl --user daemon-reload
    systemctl --user enable junctionbox-api.service junctionboxd.service
    systemctl --user restart junctionbox-api.service junctionboxd.service

    # Enable linger so services survive logout
    loginctl enable-linger "$(whoami)" 2>/dev/null || true

    echo "Installed and started."
    echo "  Open: http://127.0.0.1:8000"
    echo "  Logs: journalctl --user -u junctionbox-api -f"
    echo "        journalctl --user -u junctionboxd -f"
    echo "  Restart: systemctl --user restart junctionbox-api"
    echo "  To expose beyond localhost, edit JUNCTIONBOX_API_HOST in"
    echo "  $SYSTEMD_DIR/junctionbox-api.service (127.0.0.1 by default)."
    echo "  Uninstall: $DEPLOY_DIR/uninstall-services.sh"
fi

# Private, on-box search for agents (SearXNG) -- installed by default so
# search works out of the box with no third-party API key and no per-query
# billing. Not fatal if it fails (e.g. no network during install); JunctionBox
# still runs fine without it, agents just won't have a search tool.
"$DEPLOY_DIR/install-searxng.sh" || echo "Warning: private search setup failed -- JunctionBox will still work, agents just won't have a search tool. Re-run deploy/install-searxng.sh later to retry."
