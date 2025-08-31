# Agents Guidelines (Codex, etc.)

## Objective
Extend MonaRepo by adding **modules** (idempotent bash units) and **recipes** (orchestration) while keeping TUI flows simple and reliable.

## Acceptance Criteria
- All new bash files pass ShellCheck in CI.
- Provide at least one BATS test per new module (probe stubs acceptable).
- No destructive defaults; show preview and ask confirmation before risky changes.
- Support `--dry-run` across modules via `apply` helper.
- Idempotency: running twice does not break or duplicate state.
- Logs are clear and prefixed with `[mona]`.

## Tasks (Initial Backlog)
1. **lib**: Extract `log`, `warn`, `err`, `pm_detect`, `pkg_install`, `apply` helpers into `lib/*.sh` and refactor callers.
2. **network**: Add NMCLI path for non-Netplan distros; add detection and preview diff.
3. **users**: Add group management, shell validation, and sudoers drop-in in `/etc/sudoers.d/` with visudo check.
4. **docker**: Add uninstall/cleanup routine; detect WSL/containers; add compose plugin fallback.
5. **coolify**: Create module for pre-reqs and service bootstrap (labels, folders).
6. **wireguard**: Implement generator for wg config (with safe file permissions).
7. **inventory**: Add YAML-driven host selection for multi-host mode; `mona run <recipe> --hosts <h1,h2,...>`.
8. **cloud-init**: Parameterize repo URL/branch and recipe; support Hetzner/Proxmox variants.
9. **observability**: Optional exporters (node-exporter, cadvisor) via recipe toggle.
10. **docs**: Add screenshots/gifs of TUI and example runs.

## Conventions
- Filenames: `kebab-case.sh`
- `set -euo pipefail` at top of every script
- Use `trap` for cleanup if creating temp files
- Prefer POSIX sh where feasible; when not, document Bashisms.
