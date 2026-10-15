# JunctionBox — Third-Party Notices

JunctionBox includes third-party and open-source software components,
each remaining subject to its own copyright notices and license terms
(see `deploy/EULA.md` Section 23). This file lists every component in the
actual pinned/production dependency closure that ships with JunctionBox
Engine, generated directly from `backend/requirements.txt` and
`frontend/package.json` rather than compiled by hand — see the
regeneration instructions below.

## Copyleft component — read this one

**`paramiko` 3.5.1** is licensed under the **GNU Lesser General Public
License (LGPL)**, not a permissive license like the rest of this list.
JunctionBox uses it as an ordinary Python import (SSH support for the
Boxes feature), unmodified — it is not statically linked into a compiled
binary. This is the normal, low-risk way to consume an LGPL Python
library, but LGPL compliance is a real legal question, not a formality:
if `paramiko` is ever modified, vendored, or statically linked in a future
change, get that reviewed before shipping it.

Every other component below is under a permissive license (MIT, BSD,
Apache-2.0, ISC, or similar) with no comparable restriction.

## Regenerating this file

Run this after any dependency change, before cutting a release:

```bash
# Backend (from backend/requirements.txt's pinned closure)
python3 -m venv /tmp/license-venv && source /tmp/license-venv/bin/activate
pip install -q -r backend/requirements.txt pip-licenses
pip-licenses --format=json --with-urls > /tmp/py-licenses.json

# Frontend (production dependencies only -- excludes devDependencies,
# which never ship in the built frontend/dist/ output)
cd frontend && npx license-checker --production --json --excludePrivatePackages > /tmp/npm-licenses.json
```

Then rebuild the two tables below from those JSON files.

## Backend (Python) Dependencies

Generated from `backend/requirements.txt`'s pinned dependency closure (see that file's own header for how to reproduce this list) via `pip-licenses`.

| Package | Version | License |
|---|---|---|
| aiohappyeyeballs | 2.7.1 | Python Software Foundation License |
| aiohttp | 3.14.3 | Apache-2.0 AND MIT |
| aiosignal | 1.4.0 | Apache Software License |
| annotated-doc | 0.0.5 | MIT |
| annotated-types | 0.8.0 | MIT |
| anthropic | 0.117.0 | MIT License |
| anyio | 4.14.2 | MIT |
| attrs | 26.1.0 | MIT |
| bcrypt | 5.0.0 | Apache Software License |
| certifi | 2026.7.22 | Mozilla Public License 2.0 (MPL 2.0) |
| cffi | 2.1.0 | MIT-0 |
| charset-normalizer | 3.4.9 | MIT |
| click | 8.4.2 | BSD-3-Clause |
| cryptography | 48.0.0 | Apache-2.0 OR BSD-3-Clause |
| distro | 1.9.0 | Apache Software License |
| docstring_parser | 0.18.0 | MIT License |
| fastapi | 0.139.2 | MIT |
| frozenlist | 1.8.0 | Apache-2.0 |
| h11 | 0.16.0 | MIT License |
| http_ece | 1.2.1 | MIT License |
| httpcore | 1.0.9 | BSD-3-Clause |
| httptools | 0.8.0 | MIT |
| httpx | 0.28.1 | BSD License |
| idna | 3.18 | BSD-3-Clause |
| jiter | 0.16.0 | MIT |
| multidict | 6.7.1 | Apache License 2.0 |
| openai | 2.41.1 | Apache Software License |
| paramiko | 3.5.1 | GNU Library or Lesser General Public License (LGPL) |
| propcache | 0.5.2 | Apache Software License |
| py-vapid | 1.9.4 | MPL-2.0 |
| pycparser | 3.0 | BSD-3-Clause |
| pydantic | 2.13.2 | MIT |
| pydantic_core | 2.46.2 | MIT |
| PyNaCl | 1.6.2 | Apache Software License |
| python-dotenv | 1.2.2 | BSD-3-Clause |
| pywebpush | 2.3.0 | MPL-2.0 |
| PyYAML | 6.0.3 | MIT License |
| requests | 2.34.2 | Apache Software License |
| sniffio | 1.3.1 | Apache Software License; MIT License |
| starlette | 1.3.1 | BSD-3-Clause |
| tqdm | 4.70.0 | MPL-2.0 AND MIT |
| typing-inspection | 0.4.2 | MIT |
| typing_extensions | 4.16.0 | PSF-2.0 |
| urllib3 | 2.7.0 | MIT |
| uvicorn | 0.51.0 | BSD-3-Clause |
| uvloop | 0.22.1 | Apache Software License; MIT License |
| watchfiles | 1.2.0 | MIT License |
| websockets | 17.0.1 | BSD-3-Clause |
| yarl | 1.24.5 | Apache-2.0 |

## Frontend (JavaScript/TypeScript) Dependencies

Generated from `frontend/package.json`'s production dependency closure (`npx license-checker --production`).

| Package | Version | License |
|---|---|---|
| @floating-ui/core | 1.8.0 | MIT |
| @floating-ui/dom | 1.8.0 | MIT |
| @floating-ui/react-dom | 2.1.9 | MIT |
| @floating-ui/utils | 0.2.12 | MIT |
| @monaco-editor/loader | 1.7.0 | MIT |
| @monaco-editor/react | 4.7.0 | MIT |
| @phosphor-icons/react | 2.1.10 | MIT |
| @radix-ui/primitive | 1.1.5 | MIT |
| @radix-ui/react-arrow | 1.1.11 | MIT |
| @radix-ui/react-checkbox | 1.3.7 | MIT |
| @radix-ui/react-collection | 1.1.12 | MIT |
| @radix-ui/react-compose-refs | 1.1.3 | MIT |
| @radix-ui/react-context | 1.2.0 | MIT |
| @radix-ui/react-dialog | 1.1.19 | MIT |
| @radix-ui/react-direction | 1.1.2 | MIT |
| @radix-ui/react-dismissable-layer | 1.1.15 | MIT |
| @radix-ui/react-dropdown-menu | 2.1.20 | MIT |
| @radix-ui/react-focus-guards | 1.1.4 | MIT |
| @radix-ui/react-focus-scope | 1.1.12 | MIT |
| @radix-ui/react-id | 1.1.2 | MIT |
| @radix-ui/react-label | 2.1.11 | MIT |
| @radix-ui/react-menu | 2.1.20 | MIT |
| @radix-ui/react-popper | 1.3.3 | MIT |
| @radix-ui/react-portal | 1.1.13 | MIT |
| @radix-ui/react-presence | 1.1.7 | MIT |
| @radix-ui/react-primitive | 2.1.7 | MIT |
| @radix-ui/react-radio-group | 1.4.3 | MIT |
| @radix-ui/react-roving-focus | 1.1.15 | MIT |
| @radix-ui/react-slot | 1.3.0 | MIT |
| @radix-ui/react-switch | 1.3.3 | MIT |
| @radix-ui/react-tabs | 1.1.17 | MIT |
| @radix-ui/react-use-callback-ref | 1.1.2 | MIT |
| @radix-ui/react-use-controllable-state | 1.2.3 | MIT |
| @radix-ui/react-use-effect-event | 0.0.3 | MIT |
| @radix-ui/react-use-is-hydrated | 0.1.1 | MIT |
| @radix-ui/react-use-layout-effect | 1.1.2 | MIT |
| @radix-ui/react-use-previous | 1.1.2 | MIT |
| @radix-ui/react-use-rect | 1.1.2 | MIT |
| @radix-ui/react-use-size | 1.1.2 | MIT |
| @radix-ui/rect | 1.1.2 | MIT |
| @reduxjs/toolkit | 2.12.0 | MIT |
| @remix-run/router | 1.23.3 | MIT |
| @standard-schema/spec | 1.1.0 | MIT |
| @standard-schema/utils | 0.3.0 | MIT |
| @tanstack/query-core | 5.101.2 | MIT |
| @tanstack/react-query | 5.101.2 | MIT |
| @types/d3-array | 3.2.2 | MIT |
| @types/d3-color | 3.1.3 | MIT |
| @types/d3-ease | 3.0.2 | MIT |
| @types/d3-interpolate | 3.0.4 | MIT |
| @types/d3-path | 3.1.1 | MIT |
| @types/d3-scale | 4.0.9 | MIT |
| @types/d3-shape | 3.1.8 | MIT |
| @types/d3-time | 3.0.4 | MIT |
| @types/d3-timer | 3.0.2 | MIT |
| @types/prop-types | 15.7.15 | MIT |
| @types/react | 18.3.31 | MIT |
| @types/react-dom | 18.3.7 | MIT |
| @types/trusted-types | 2.0.7 | MIT |
| @types/use-sync-external-store | 0.0.6 | MIT |
| @xterm/addon-fit | 0.11.0 | MIT |
| @xterm/xterm | 6.0.0 | MIT |
| aria-hidden | 1.2.6 | MIT |
| class-variance-authority | 0.7.1 | Apache-2.0 |
| clsx | 2.1.1 | MIT |
| csstype | 3.2.3 | MIT |
| d3-array | 3.2.4 | ISC |
| d3-color | 3.1.0 | ISC |
| d3-ease | 3.0.1 | BSD-3-Clause |
| d3-format | 3.1.2 | ISC |
| d3-interpolate | 3.0.1 | ISC |
| d3-path | 3.1.0 | ISC |
| d3-scale | 4.0.2 | ISC |
| d3-shape | 3.2.0 | ISC |
| d3-time | 3.1.0 | ISC |
| d3-time-format | 4.1.0 | ISC |
| d3-timer | 3.0.1 | ISC |
| decimal.js-light | 2.5.1 | MIT |
| detect-node-es | 1.1.0 | MIT |
| dompurify | 3.4.12 | (MPL-2.0 OR Apache-2.0) |
| es-toolkit | 1.49.0 | MIT |
| eventemitter3 | 5.0.4 | MIT |
| get-nonce | 1.0.1 | MIT |
| immer | 11.1.15 | MIT |
| internmap | 2.0.3 | ISC |
| js-tokens | 4.0.0 | MIT |
| loose-envify | 1.4.0 | MIT |
| lucide-react | 0.412.0 | ISC |
| marked | 14.0.0 | MIT |
| monaco-editor | 0.55.1 | MIT |
| react | 18.3.1 | MIT |
| react-dom | 18.3.1 | MIT |
| react-is | 19.2.7 | MIT |
| react-redux | 9.3.0 | MIT |
| react-remove-scroll | 2.7.2 | MIT |
| react-remove-scroll-bar | 2.3.8 | MIT |
| react-router | 6.30.4 | MIT |
| react-router-dom | 6.30.4 | MIT |
| react-style-singleton | 2.2.3 | MIT |
| recharts | 3.9.2 | MIT |
| redux | 5.0.1 | MIT |
| redux-thunk | 3.1.0 | MIT |
| reselect | 5.2.0 | MIT |
| scheduler | 0.23.2 | MIT |
| state-local | 1.0.7 | MIT |
| tailwind-merge | 2.6.1 | MIT |
| tiny-invariant | 1.3.3 | MIT |
| tslib | 2.8.1 | 0BSD |
| use-callback-ref | 1.3.3 | MIT |
| use-sidecar | 1.1.3 | MIT |
| use-sync-external-store | 1.6.0 | MIT |
| victory-vendor | 37.3.6 | MIT AND ISC |

Full per-package license text is available in each package's own
distribution (`node_modules/<package>/LICENSE` and the installed Python
package's own metadata) and is not reproduced here in full; this table is
the attribution and license-identification record itself.
