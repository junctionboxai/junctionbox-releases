#!/usr/bin/env bash
# Uninstall JunctionBox: stops and disables the background services
# (systemd --user on Linux, launchd user agents on macOS), removes the
# installed binaries/frontend bundle and the service definitions. By
# default this leaves ~/.junctionbox/ (database, secrets, job logs,
# installed plugins) untouched -- pass --purge-data (or answer 'y' at the
# prompt) to wipe that too.
set -e

INSTALL_DIR="$HOME/.junctionbox"
OS="$(uname -s)"
PURGE_DATA=0

for arg in "$@"; do
    case "$arg" in
        --purge-data) PURGE_DATA=1 ;;
        *) echo "unknown argument: $arg" >&2; exit 1 ;;
    esac
done

if [ "$OS" = "Darwin" ]; then
    LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
    echo "== Stopping and unloading launchd services =="
    for label in com.junctionbox.junctionbox-api com.junctionbox.junctionboxd com.junctionbox.junctionbox-searxng; do
        launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
    done

    echo "== Removing launchd plist files =="
    rm -f "$LAUNCH_AGENTS_DIR"/com.junctionbox.junctionbox-api.plist \
          "$LAUNCH_AGENTS_DIR"/com.junctionbox.junctionboxd.plist \
          "$LAUNCH_AGENTS_DIR"/com.junctionbox.junctionbox-searxng.plist
else
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    echo "== Stopping services =="
    systemctl --user stop junctionbox-api.service junctionboxd.service junctionbox-searxng.service 2>/dev/null || true
    systemctl --user disable junctionbox-api.service junctionboxd.service junctionbox-searxng.service 2>/dev/null || true

    echo "== Removing systemd unit files =="
    rm -f "$SYSTEMD_DIR/junctionbox-api.service" "$SYSTEMD_DIR/junctionboxd.service" "$SYSTEMD_DIR/junctionbox-searxng.service"
    systemctl --user daemon-reload
fi

echo "== Removing installed binaries and frontend bundle =="
rm -rf "$INSTALL_DIR/bin" "$INSTALL_DIR/frontend-dist"

if [ "$PURGE_DATA" -eq 0 ]; then
    read -r -p "Also delete all JunctionBox data at $INSTALL_DIR (database, secrets, job logs, installed plugins, SearXNG)? [y/N] " reply
    case "$reply" in
        [yY]|[yY][eE][sS]) PURGE_DATA=1 ;;
        *) PURGE_DATA=0 ;;
    esac
fi

if [ "$PURGE_DATA" -eq 1 ]; then
    echo "== Deleting $INSTALL_DIR =="
    rm -rf "$INSTALL_DIR"
else
    echo "Kept $INSTALL_DIR (database, secrets, job logs, installed plugins). Delete it manually later if you want a truly clean slate."
fi

echo
echo "JunctionBox services uninstalled."
