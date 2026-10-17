# JunctionBox Secure Deployment

JunctionBox is password-protected after localhost-only setup. Browser sessions use an HttpOnly, SameSite=Strict cookie plus a double-submit CSRF cookie. Session cookies automatically receive the `Secure` attribute when JunctionBox sees HTTPS. Set `JUNCTIONBOX_SECURE_COOKIES=true` on `junctionbox-api` when TLS terminates upstream and scheme forwarding is unavailable.

The web UI is served directly by `junctionbox-api.service` (no separate frontend process in a real install); `junctionboxd.service` is the background execution daemon. `junctionbox-frontend.service`, a `npm run dev` process, is a local-development-only convenience and is never part of an installed release.

## Initial setup

Complete `/api/auth/setup` from the JunctionBox host itself. Requests arriving from a non-loopback client, including a forwarded external address, are rejected. Before setup completes, every non-public API route and both WebSocket endpoints remain locked.

## HTTPS reverse proxy

`install-services.sh` sets this up automatically (`deploy/install-https-proxy.sh`) — a self-signed-cert Caddy instance in front of `junctionbox-api`, reachable at `https://<LAN IP>:8443` (or the next free port). `junctionbox-api` itself is never exposed directly; this proxy is the only thing actually reachable from another device. Not fatal if it fails (no network at install time, or a genuinely unsupported OS/arch) — JunctionBox still works fine at `http://127.0.0.1:8000` locally either way. Re-run it manually any time, e.g. after the LAN IP changes.

Initial setup (`/api/auth/setup`, before a password exists) is rejected through this proxy on purpose — see "Initial setup" above — complete it from `127.0.0.1` on the host itself, or via `ssh -L 8000:localhost:8000 user@host` and browse to `localhost:8000` from your own machine. Everyday access afterward works fine through the HTTPS URL.

To run your own reverse proxy instead (nginx, a different Caddy setup, something in front of a non-default port), expose the browser through one HTTPS origin and proxy both `/api` and `/ws` to port 8000. Preserve the original client and scheme:

```nginx
location /api/ {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location /ws/ {
    proxy_pass http://127.0.0.1:8000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Only trust forwarding headers from a locally controlled proxy. Do not expose port 8000 separately when the reverse proxy is the public entry point.

## Non-browser API clients

API clients can explicitly request a bearer session during login:

```bash
curl -sS -X POST https://junctionbox.example/api/auth/login \
  -H 'Content-Type: application/json' \
  -H 'X-JunctionBox-Auth-Mode: bearer' \
  -d '{"password":"..."}'
```

Send the returned token as `Authorization: Bearer ...`. Bearer requests do not require a CSRF header. Browser clients should use the cookie flow and must not copy session values into URLs.

## Audit history

Settings → Security Audit shows recent authentication, agent-run, permission/configuration, credential/tool, webhook, SSH bootstrap, backup-restore, and other mutation events. Audit rows contain request metadata and status only; request bodies and secrets are never stored.
