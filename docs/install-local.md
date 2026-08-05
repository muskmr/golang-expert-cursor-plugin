# Install Golang Lifecycle Toolkit locally in Cursor

Use this when you want to run the plugin on your machine before (or without)
Marketplace listing.

## Requirements

- Cursor desktop (macOS, Linux, or Windows)
- This repository checked out locally
- Optional: Go toolchain + `gopls` (`go install golang.org/x/tools/gopls@latest`) for MCP

## Quick install

### macOS / Linux

```bash
git clone https://github.com/muskmr/golang-expert-cursor-plugin.git
cd golang-expert-cursor-plugin
./scripts/install-local.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/muskmr/golang-expert-cursor-plugin.git
cd golang-expert-cursor-plugin
powershell -ExecutionPolicy Bypass -File .\scripts\install-local.ps1
```

The installer **copies** `plugins/golang-lifecycle` into:

```text
~/.cursor/plugins/local/golang-lifecycle
```

It also rewrites `logo` in the **installed copy** of `plugin.json` to an absolute
`file://…` URL pointing at `assets/logo.png`, so the plugin icon loads in Cursor
even when relative logo paths are resolved as GitHub raw URLs (marketplace behaviour).

`--link` mode skips that rewrite so your git checkout stays clean; use copy mode
when you need the local logo for demos/screenshots.

## After install

1. Cursor → Command Palette → **Developer: Reload Window**
2. Ensure **Include third-party Plugins, Skills, and other configs** is enabled
   (Team/Enterprise admins may need to allow user-local plugins)
3. Open **Plugins** / **Customize** — you should see **Golang Lifecycle Toolkit**
   with the GO logo
4. In Agent chat try `/go-analyze` or `/go-diagram`

## Iteration while developing

```bash
./scripts/install-local.sh --link    # symlink the plugin folder (faster)
# edit files under plugins/golang-lifecycle
# Reload Window again
```

If Cursor rejects an external symlink, the script falls back to copy
automatically. Prefer copy for a stable local demo.

## Uninstall

```bash
./scripts/uninstall-local.sh
```

Then **Developer: Reload Window**.

## Verify layout

The installed plugin root must contain the manifest (not the marketplace repo root):

```text
~/.cursor/plugins/local/golang-lifecycle/
├── .cursor-plugin/plugin.json   ← required at this level
├── assets/logo.svg
├── assets/logo.png              ← used for local UI logo
├── rules/
├── skills/
├── agents/
├── commands/
├── hooks/
├── scripts/
└── mcp.json
```

Do **not** symlink the whole git repo into `local/` — `plugin.json` would be nested
under `plugins/golang-lifecycle/` and Cursor will not load it.

## Logo notes

| Context | How the logo is referenced |
| --- | --- |
| Git / Marketplace | Relative `assets/logo.svg` in `plugin.json` (resolves via GitHub raw) |
| Local install | Installer sets `logo` to `file:///…/assets/logo.png` |

Assets committed in the repo: `logo.svg`, `logo.png`, `logo-128.png`,
`logo-256.png`, `logo-512.png`.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Plugin missing after reload | Confirm path is `~/.cursor/plugins/local/…` (not `plugins/cache/`). Enable third-party plugins. On Team plans, ask admin to allow user-local plugins. |
| Logo missing | Re-run `./scripts/install-local.sh` (not `--link` if symlink blocked). Confirm `assets/logo.png` exists in the install dir and `plugin.json` `logo` starts with `file:`. |
| Hooks not running | Open Cursor **Hooks** output channel; confirm `hooks/hooks.json` is present in the install. |
| `gopls` MCP fails | Install gopls on `PATH`, or ignore MCP — rules/skills/commands still work. |
