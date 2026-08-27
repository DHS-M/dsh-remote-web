# DSH Remote Web

**DSH Remote Web** is a reproducible distribution of the DeepSeek Harness modified for browser-only remote operation. It preserves the official Harness architecture while adding an explicit core-level `--open-authority` mode, host-authority propagation to the browser, and web-native configuration editing.

> This product intentionally grants every caller who can reach the service the same host authority as the local Harness user. Do not expose it to an untrusted network without adding an external access boundary such as a private network, identity-aware proxy, or firewall.

## Install from scratch

The installer clones the official Harness at the pinned upstream commit, applies the reviewed patch, installs the workspace dependencies, and builds the client, host, and web assets.

```bash
curl -fsSL https://raw.githubusercontent.com/kenqtade/dsh-remote-web/main/install.sh -o install.sh
chmod +x install.sh
BUILD=1 ./install.sh "$HOME/dsh-remote-web"
cd "$HOME/dsh-remote-web"
```

The installer can skip the build when you only need to inspect the patched checkout:

```bash
BUILD=0 ./install.sh "$HOME/dsh-remote-web"
```

## Run the web interface

```bash
cd "$HOME/dsh-remote-web"
pnpm dsh web --host 0.0.0.0 --open-authority --no-open
```

The browser interface is served on port `3080`. Put it behind your preferred secure tunnel or reverse proxy. A Cloudflare Quick Tunnel can be used for temporary testing:

```bash
cloudflared tunnel --url http://127.0.0.1:3080
```

## What is included

The patch centralizes authority at the connection and ApiProxy layers instead of modifying individual `/api` routes. In open mode, HTTP requests, WebSocket upgrades, shared RPC interceptors, and dedicated RPC channels accept reachable callers. The browser receives the server-declared authority and uses host-backed settings rather than the old non-loopback memory fallback.

The Settings panel includes an in-page editor for the host-owned `settings.yaml` document. The editor reads and writes the document through typed RPC methods and does not launch an editor on the server desktop. Remote workspaces use the existing host filesystem browser for directory listing and folder creation. Session results and downloads remain browser-visible.

The DeepSeek provider is not included in the active base composition. Its source package remains available in the workspace for optional overlays; the default active configuration uses the remaining configured provider surface.

## Product boundaries

This repository contains the installer and the exact binary patch against the official upstream commit. It does not delete the official source packages, rewrite unrelated plugins, or claim that a server-native desktop dialog can be rendered inside a remote browser. Capabilities that require a physical desktop are represented by browser-safe adapters where available.

## Documentation

The web documentation is in [`docs/index.html`](docs/index.html). The pinned upstream commit is recorded in [`UPSTREAM-COMMIT.txt`](UPSTREAM-COMMIT.txt), and the patch is in [`patches/open-authority-web-only.patch`](patches/open-authority-web-only.patch).

## License and attribution

The Harness remains based on the official DeepSeek Harness. Review [`UPSTREAM-LICENSE`](UPSTREAM-LICENSE) and the upstream repository at <https://github.com/deepseek-ai/deepseek-harness> before redistribution.
