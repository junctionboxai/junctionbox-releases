# JunctionBox Plugin Creation Context

You are helping build a JunctionBox plugin — an installable extension with its own backend router, its own sandboxed frontend, and (usually) its own SQLite tables, distinct from JunctionBox's own core. You do not need or get access to JunctionBox's core source to do this; everything a plugin needs is described here. Installing a plugin is fully self-service: any manifest declaring a unique, well-formed id installs and (after a restart of the JunctionBox process) runs immediately — there is no maintainer review step, no whitelist of already-known plugin ids to get past.

## Package format

A plugin ships as a ZIP containing:

- `junctionbox-plugin.json` — the manifest, at the ZIP root:
  ```json
  {
    "format": "junctionbox-plugin",
    "version": 2,
    "id": "your-plugin-id",
    "name": "Your Plugin Name",
    "description": "One sentence describing what it does.",
    "nav": { "label": "Your Plugin Name", "icon": "icon.svg" },
    "frontend": { "entry": "index.html" }
  }
  ```
  - `id` is lowercase, hyphenated (e.g. `weather-alerts`), and stable — it becomes both the plugin's own directory name on install and its API route prefix (`/api/plugins/your-plugin-id`).
  - `nav.label` is what shows in the sidebar; `nav.icon` is optional, a path to an image file inside your own `frontend/` directory (e.g. `"icon.svg"` if you ship `frontend/icon.svg`) — omit it (or set `null`) to get a generic fallback icon instead. There is no shared icon set to reference by name; your plugin doesn't share JunctionBox's own compiled frontend at all (see "Frontend conventions" below).
  - `frontend.entry` is the HTML file JunctionBox loads to start your plugin's UI, relative to your own `frontend/` directory. Defaults to `index.html` if omitted.
- `backend/` — a Python package, required files:
  - `backend/__init__.py` — can be empty; it just makes the directory an importable package.
  - `backend/router.py` — must define a top-level `router` (a `fastapi.APIRouter`) whose `prefix` is exactly `/api/plugins/your-plugin-id` — a mismatched prefix is rejected at load time, not silently allowed. Optionally also a top-level `mcp_router` if the plugin exposes MCP tools to agents (see below).
- `frontend/` — **a pre-built, self-contained static bundle** (HTML/JS/CSS), not React/TypeScript source JunctionBox compiles for you. Use whatever framework or toolchain you want (plain HTML+JS, React, Vue, htmx, anything) — build it yourself and ship the output. At minimum, `frontend/index.html` (or whatever `frontend.entry` names) plus any assets it references.

Package limits: 25 MB max, no absolute paths or `..` path segments in any archive entry (rejected as unsafe), and the archive must contain both a `backend/` and a `frontend/` directory matching the required-file check above.

## Producing the ZIP — required, do this last

Writing the `junctionbox-plugin.json`, `backend/`, and `frontend/` files is not the deliverable by itself — **the deliverable is the `.zip` file itself.** A finished plugin whose files exist on disk but were never actually archived is not done. Once every file above is written, package them yourself as the final step, e.g. from a shell in your plugin's source root (containing `junctionbox-plugin.json`, `backend/`, and `frontend/` as siblings):

```bash
zip -r ../your-plugin-id.zip junctionbox-plugin.json backend frontend
```

If `zip` isn't available, use this dependency-free Python equivalent instead (run from the same directory):

```bash
python3 - <<'EOF'
import zipfile
from pathlib import Path

root = Path(".")
out = Path("your-plugin-id.zip")  # replace with your actual plugin id
with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_DEFLATED) as archive:
    archive.write(root / "junctionbox-plugin.json", "junctionbox-plugin.json")
    for sub in ("backend", "frontend"):
        for path in (root / sub).rglob("*"):
            if path.is_file():
                archive.write(path, path.relative_to(root))
print(f"wrote {out} ({out.stat().st_size} bytes)")
EOF
```

Before finishing, verify the archive actually contains what it should — an empty or malformed zip is worse than no zip, since it looks done at a glance:

```bash
unzip -l your-plugin-id.zip
```

Confirm the listing shows `junctionbox-plugin.json` at the root plus files under both `backend/` and `frontend/`. A plugin build is not complete until this zip exists and has been verified this way.

To actually install it: Settings → Plugins → "Browse for plugin ZIP". New backend routes mount on the next start of the JunctionBox process. On a development install — uvicorn running with `--reload` watching `~/.junctionbox/plugins`, as on this machine — that happens on its own whenever plugin files change under `~/.junctionbox/plugins/<id>/`, so editing the installed files is enough and no restart is needed. On a packaged install, someone with shell access restarts the service (`systemctl --user restart junctionbox-api junctionboxd`, or however that install is run).

If you are an agent running *inside* a live JunctionBox instance, never restart, stop, or kill `junctionbox-api`, `junctionboxd`, or `junctionbox-frontend` yourself, by any mechanism — those services are executing your run, so restarting one terminates you mid-task and the user gets no answer. Make the change, and if it genuinely cannot take effect without a core-service restart, finish everything else and say so plainly in your final message instead of doing it.

Tell the user the absolute path where the zip landed, in plain text (e.g. "Built and saved to `/home/user/junctionbox/plugins/packages/your-plugin-id.zip`"). **Never** wrap that path in markdown link syntax (`[text](/some/local/path)`) — a local filesystem path is not a URL, no browser can fetch it, and a fake-looking "Download" link that silently does nothing is worse than no link at all. If you were asked to deliver the file through some other real channel available to you (a genuine attachment mechanism, an actual HTTP download route), use that instead — but a markdown link pointing at a bare local path is never correct.

## Backend router conventions

Follow the same patterns JunctionBox's own plugins use:

- Prefix your router exactly: `router = APIRouter(prefix="/api/plugins/your-plugin-id", tags=["your-plugin-id"])` — this must match your manifest's `id` exactly, or your plugin fails to load (logged, skipped, doesn't crash the rest of JunctionBox).
- Persist your own state in new SQLite tables (created idempotently, e.g. `CREATE TABLE IF NOT EXISTS ...` run at import/startup) rather than touching any core JunctionBox table.
- **The database is raw `sqlite3` — there is no ORM. Do not import or install SQLAlchemy, `create_engine`, `declarative_base`, sessions, or any ORM.** `app.db.get_db()` is a context manager that yields a plain `sqlite3.Connection` (with `row_factory = sqlite3.Row`, so rows are dict-like). Every JunctionBox table — core and plugin — is managed with hand-written SQL strings. The whole pattern:

  ```python
  from app.db import get_db

  def ensure_schema() -> None:
      with get_db() as conn:
          conn.execute("""
              CREATE TABLE IF NOT EXISTS myplugin_items (
                  id         TEXT PRIMARY KEY,
                  name       TEXT NOT NULL,
                  created_at TEXT NOT NULL DEFAULT (datetime('now'))
              )
          """)
          conn.commit()

  ensure_schema()  # at module import — runs once when the plugin backend loads

  def create_item(name: str) -> dict:
      item_id = uuid.uuid4().hex[:12]
      with get_db() as conn:
          conn.execute("INSERT INTO myplugin_items (id, name) VALUES (?, ?)", (item_id, name))
          conn.commit()
      return get_item(item_id)

  def get_item(item_id: str) -> dict | None:
      with get_db() as conn:
          row = conn.execute("SELECT * FROM myplugin_items WHERE id = ?", (item_id,)).fetchone()
      return dict(row) if row else None
  ```

  Prefix every table name with your plugin id (`myplugin_`) so it never collides with a core table or another plugin's. Use `?` placeholders, never string interpolation. Copy this pattern verbatim from any shipped plugin's `service.py` (e.g. `stickers`, `storyboard`) if you want a fuller example — do not reinvent the data layer.
- Encrypt any credential your plugin stores (API keys, tokens, passwords) using `app.secrets.encrypt_secret`/`decrypt_secret` — every credentialed table in JunctionBox already follows this, and plugin credentials should be no different.
- If your plugin needs to expose tools to agents, prefer the existing MCP mechanism (a separate `mcp_router` with secret-authenticated, loopback-only endpoints, following the same pattern E*TRADE and Kubernetes use) over inventing a new integration point. Any path under your `mcp_router`'s prefix (`/api/plugins/your-plugin-id/mcp/...`) is automatically reachable without a session or plugin token — that's what lets a sandboxed MCP subprocess call it at all — so your own endpoint must do its own secret check (e.g. `hmac.compare_digest` against a per-installation secret you generate and store encrypted) before trusting the request. This needs no core edit and no manual registration on JunctionBox's side; it's automatic for any plugin id.
- Never accept a raw shell string or free-text command from a user or an agent and execute it directly — build commands from structured, validated parameters and execute as an argv list, the same convention every existing plugin already follows.
- If your plugin fires recurring background work, prefer reusing JunctionBox's existing `schedules`/job-runner machinery over building a second scheduler.
- Your route handlers can freely `import` anything JunctionBox's own core already imports (`fastapi`, `app.db`, `app.secrets`, `httpx`, `cryptography`, `paramiko`, `python-multipart` for `File`/`UploadFile` form uploads, etc.) with zero extra work. A third-party package JunctionBox doesn't already use may not be available — if you need one, vendor it yourself: `pip install --target ./backend/vendor <package>` before zipping, and add `sys.path.insert(0, str(Path(__file__).parent / "vendor"))` near the top of `router.py`. Pure-Python packages vendor cleanly this way; packages with compiled C extensions need a wheel matching JunctionBox's own Python version and platform, which is a real, sharper edge — prefer pure-Python dependencies when you have a choice.
- One vendoring failure mode worth knowing about: this trick only works for a package *your own router.py* imports directly. It silently does not work for a package one of JunctionBox's core dependencies resolves and caches at *its own* import time — by the time your plugin's `sys.path.insert` runs, that resolution already happened, using whatever was importable at process startup, before any plugin loaded. `python-multipart` hit exactly this (Starlette resolves and caches its multipart parser the moment `starlette.requests` is first imported, which happens immediately via FastAPI, long before plugin discovery runs) — every plugin vendoring it got a generic `400 "There was an error parsing the body"` on every real upload, despite the vendored package being present and correctly structured, and despite unit tests (which call endpoint functions directly, bypassing Starlette's body-parsing layer) passing cleanly. This is why `python-multipart` is now a real core dependency instead of something plugins vendor — if you hit an unexplained failure that only reproduces against the real running server, never in a unit test, suspect this same class of bug.

### Optional tool discoverability metadata

For Anthropic and Ollama-routed agents specifically (Claude CLI and Grok CLI get your tool's full schema natively and don't need any of this), JunctionBox never attaches every installed tool's full schema to every request — the model gets a compact, character-budgeted index of names and one-line descriptions instead, and asks for more only when it needs it (`backend/app/tool_dispatcher.py`). Under a tight budget, your tool's description can be truncated to a bare name. To help an agent actually call your tool correctly despite that, your tool's dict (in your `mcp_server.py`'s `TOOLS` list) can optionally carry four extra keys, alongside the standard `name`/`description`/`inputSchema` — plain JSON, never validated or stripped, so they're free to add:

- `input_complexity`: `"simple"`, `"moderate"`, or `"complex"` — how hard your tool is to call correctly. A tool tagged `"complex"` gets preferential treatment when the index's tight character budget can't fit every tool's full description, since a self-explanatory tool doesn't need one to be called correctly, but a complex one does. Omit it and your tool is treated as `"moderate"`.
- `usage_notes`: a short string capturing tacit knowledge a JSON Schema can't express on its own — an argument ordering requirement, a units/indexing gotcha, a common mistake.
- `examples`: a list of `{"arguments": {...}, "note": "..."}` — concrete worked calls. Models generalize from a real example more reliably than from an abstract schema, especially for a tool with several optional/interacting parameters.
- `preconditions`: a short string naming what has to be true or configured for your tool to actually work (e.g. "requires a ComfyUI server registered under Settings") — lets an agent check first instead of guessing and failing.

None of these are ever required, and a tool that omits all four (including every third-party MCP server you didn't write) behaves exactly as it does today. They surface to the agent via `describe_tool` (a specific tool's full detail on request) and automatically in a failed call's own error message — see `age-shift-source/backend/mcp_server.py`'s `generate_age_shift` tool for a complete worked example of all four together.

## Trust model — say this plainly, don't leave it implied

**A plugin's backend code runs with the same privileges as JunctionBox's own core** — same process, same filesystem access, same database connection, unrestricted subprocess/network access. There is no sandboxing between a plugin's backend and the rest of JunctionBox. This is the same trust model as a VS Code extension or an Obsidian community plugin: installing one is an explicit, informed decision, not something to do with code you haven't reviewed or don't trust. If you're building a plugin on someone's behalf, make sure they understand this before they install it.

## Frontend conventions — a sandboxed iframe, not native JunctionBox UI

Your plugin's frontend runs inside a sandboxed `<iframe sandbox="allow-scripts allow-downloads">` (no `allow-same-origin`), served from your own pre-built `frontend/` bundle at `/plugin-assets/your-plugin-id/...`. This is deliberate: it means your plugin's frontend is never coupled to whatever React/Vite/Tailwind version JunctionBox's own core happens to be running — build and style it however you want. `allow-downloads` is there so a normal `<a download>`/blob-URL click (e.g. "export this as a file") works — Chromium silently blocks that from a sandboxed frame without it.

Match JunctionBox's own theme rather than inventing your own look — JunctionBox's UI is always dark (no light mode, no toggle: `frontend/index.html` hardcodes `<html class="dark">`), and a plugin that looks visually out of place reads as broken, not as an intentional design choice. Because the sandboxed iframe has no `allow-same-origin`, it can't read JunctionBox's actual stylesheet or CSS variables at runtime — there's no live inheritance, so hardcode these same values (copied verbatim from `frontend/src/index.css`'s `.dark` block) into your own `frontend/`'s CSS instead:

```css
:root {
  color-scheme: dark;
  --ce-bg: 225 35% 11%;
  --ce-fg: 210 20% 96%;
  --ce-card: 225 50% 7%;
  --ce-card-fg: 210 20% 96%;
  --ce-primary: 24 95% 53%;      /* JunctionBox's orange accent */
  --ce-primary-fg: 0 0% 100%;
  --ce-muted: 215 19% 17%;
  --ce-muted-fg: 215 16% 55%;
  --ce-destructive: 0 63% 40%;
  --ce-border: 215 19% 20%;
}
body { background: hsl(var(--ce-bg)); color: hsl(var(--ce-fg)); }
```

Plugin Builder's own generated scaffold (`/generate`) already starts every new plugin with this block wired in — see its `frontend/index.html` for a complete worked example (form inputs, buttons, banners, all themed off these same variables).

**Typography and page structure — match the existing built-in plugins, don't invent your own.** Every core plugin (Stickers, Storyboard, Ring Security, Age Shift, etc.) independently converged on the same conventions; follow them rather than making fresh layout/type decisions each time:

- **Font**: `Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif` on `body`. Inter is a Google Font — either link it or, safer for an offline/self-contained bundle, let it fall through to the system-ui stack; don't reach for a different display face.
- **`<title>`**: the plain plugin name, matching your manifest's `nav.label` exactly (e.g. `<title>Stickers</title>`) — even though the iframe's own `<title>` isn't what shows in JunctionBox's browser tab, keep it accurate for anyone opening the plugin's URL directly or inspecting it in devtools.
- **Page header**: an `<h1>` holding the plugin name at `font-size: 30px; line-height: 36px; font-weight: 600; letter-spacing: -.025em`, immediately followed by a one-line `<p class="subtitle">` (`font-size: 14px; color: hsl(var(--ce-muted-fg)); margin: 3px 0 0`) describing what the plugin does — sits inside a `.topbar` flex row (`justify-content: space-between; align-items: flex-end`) with the page's primary action button(s) on the right.
- **Small print/hints**: `font-size: 11px; color: hsl(var(--ce-muted-fg))` for helper text under a form field or control.
- **Cards and grids**: list/gallery content goes in `.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150-280px, 1fr)); gap: 14px }`, each item a `.card` with `border: 1px solid hsl(var(--ce-border)); border-radius: 10-12px; background: hsl(var(--ce-card))`.
- **Buttons**: a primary action uses `background: hsl(var(--ce-primary)); color: hsl(var(--ce-primary-fg))`; every other button uses `background: hsl(var(--ce-muted)); color: hsl(var(--ce-fg))` with a `1px solid hsl(var(--ce-border))` border. Status pills/badges are fully rounded (`border-radius: 999px`), small (11-13px), muted background.

See `stickers-source/frontend/index.html` or `storyboard-source/frontend/index.html` for a complete worked example of all of the above together.

**Left-align content — never center a max-width wrapper with `margin: auto`.** A confirmed, recurring mistake: a top-level `.shell { max-width: 1180px; margin: auto; padding: 28px }` (the standard pattern for a *standalone* marketing/blog page) looks visibly broken here, because your plugin doesn't render as a standalone page — it renders inside a full-height panel docked directly against JunctionBox's sidebar, the same way Home Control, Plugin Builder, and every other core page do, and every one of those is left-aligned with plain padding, never centered. Centering a narrower-than-container block inside that panel pushes your entire page's content to start dozens or hundreds of pixels to the right of where every other page in the app starts it — visually reading as a misaligned, "broken" page even though nothing else is wrong. Use `padding: 28px` (or similar) with **no** `max-width`/`margin: auto` on your outermost wrapper; let a responsive grid (`repeat(auto-fill, minmax(...))`) handle wide viewports instead of capping and centering the whole page.

Because the iframe has no `allow-same-origin`, it has **no access to JunctionBox's cookies, session, or the parent page's DOM** — by design, the same isolation JunctionBox already uses for agent-rendered Artifacts. Your plugin still needs to call its own backend routes (`/api/plugins/your-plugin-id/...`) authenticated, though, so instead of relying on cookies (which structurally cannot reach your iframe), JunctionBox hands you a short-lived, plugin-scoped bearer token over `postMessage`. The contract:

1. As soon as your page's JS is ready to receive it, post a ready signal to the parent:
   ```js
   window.parent.postMessage({ type: "junctionbox-plugin-ready" }, "*")
   ```
2. Listen for the parent's response and hold onto the token and API base it gives you:
   ```js
   let token = null, apiBase = null
   window.addEventListener("message", (e) => {
     if (e.data?.type === "junctionbox-plugin-auth") {
       token = e.data.token
       apiBase = e.data.apiBase   // "/api/plugins/your-plugin-id"
     }
   })
   ```
3. Attach the token as a normal bearer header on every fetch to your own routes:
   ```js
   fetch(apiBase + "/status", { headers: { Authorization: "Bearer " + token } })
   ```
4. The token expires after 30 minutes. If a fetch to your own API comes back `401`, ask for a fresh one and wait for the parent's response before retrying:
   ```js
   window.parent.postMessage({ type: "junctionbox-plugin-token-expired" }, "*")
   ```

The token only ever authenticates *your own* plugin's routes (`/api/plugins/your-plugin-id/...`) — it is meaningless anywhere else in JunctionBox's API, including other plugins', by design. It also can't be used to install, enable/disable, or remove any plugin (including your own) — those actions always require the real logged-in user's own session, never a plugin token, so there's no way for a plugin's own frontend code to manage plugins on its own.

Add your own typed API client functions alongside your page rather than modifying JunctionBox's core `frontend/src/lib/api.ts` — there's nothing to modify there anyway, since your plugin doesn't share that code.
