🌈✨ **MonaRepo**: monorepo de automação em **Bash** com **TUI** usando `bashsimplecurses`, para padronizar o *bootstrap* das VMs/servidores da Monynha (Hetzner, Proxmox/XCP-NG guests, etc.), incluindo preparo para Coolify, Docker, WireGuard, Postgres client, e outros babados.

# Visão & pilares

* **Um único CLI (`mona`)** que orquestra módulos Bash idempotentes (estilo “probe → apply → verify”).
* **TUI opcional** para escolher hosts/receitas via `bashsimplecurses` (janelinhas, atualização periódica; com `main()` + `main_loop` e possibilidade de interação via `update()`/`read`), deixando tudo amigável para o time. ([GitHub][1]) ([bashsimplecurses.readthedocs.io][2])
* **Primeiro-boot via cloud-init** (user-data) quando disponível, chamando o bootstrap do MonaRepo (instala pacotes, grava arquivos, executa comandos `runcmd`). ([cloudinit.readthedocs.io][3])
* **Qualidade**: lint com **ShellCheck** e testes com **BATS** (unitários de shell), integrados em CI. ([shellcheck.net][4], [GitHub][5])

---

# Estrutura do MonaRepo

```text
monarepo/
├─ bin/
│  └─ mona                 # CLI principal
├─ lib/                    # helpers bash: log, ui, ssh, os, yaml
├─ ui/
│  └─ bashsimplecurses/    # submódulo git (simple_curses.sh)
├─ modules/                # módulos atômicos (idempotentes)
│  ├─ base/                # timezone, usuários, ssh, ufw
│  ├─ docker/              # docker-ce + compose plugin
│  ├─ coolify/             # pré-requisitos, pastas, labels
│  ├─ wireguard/           # wg quick (opcional)
│  ├─ postgres-client/     # psql/pg_dump
│  └─ monitoring/          # node-exporter, etc. (opcional)
├─ recipes/                # “pacotes” de módulos por papel
│  ├─ coolify-node.sh
│  ├─ supabase-node.sh
│  └─ dev-node.sh
├─ inventory/
│  ├─ servers.yml          # hosts, grupos, tags, credenciais
│  └─ groups.yml
├─ templates/
│  ├─ cloud-init/user-data.yaml
│  └─ systemd/*
├─ tests/                  # *.bats
├─ .shellcheckrc
├─ .github/workflows/ci.yml
└─ README.md
```

> `bashsimplecurses` expõe `simple_curses.sh` e um loop “`main(); main_loop -t 1`” para desenhar janelas; também permite interação implementando `update()` e capturando teclas com `read`. ([GitHub][1], [bashsimplecurses.readthedocs.io][2])

---

# Inventário & receitas

**inventory/servers.yml** (exemplo):

```yaml
servers:
  - name: monynha-online-prod
    host: 49.13.210.48
    user: root
    os: ubuntu22
    roles: [coolify, docker]
    tags: [prod, hetzner]
  - name: lab-xcpng-01
    host: 10.0.0.50
    user: root
    os: ubuntu22
    tags: [lab, xcp-ng]
```

**recipes/coolify-node.sh** (pseudocode):

```bash
#!/usr/bin/env bash
set -euo pipefail

req "modules/base/base.sh"
req "modules/docker/install.sh"
req "modules/coolify/bootstrap.sh"

run_base
run_docker_install
run_coolify_bootstrap
```

---

# CLI (`bin/mona`) — esqueleto

```bash
#!/usr/bin/env bash
set -euo pipefail
export MONA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

. "$MONA_DIR/lib/log.sh"
. "$MONA_DIR/lib/ssh.sh"
. "$MONA_DIR/lib/yaml.sh"

cmd="${1:-help}"; shift || true

case "$cmd" in
  tui)    "$MONA_DIR/lib/tui.sh" "$@";;
  run)    recipe="$1"; shift; "$MONA_DIR/lib/run_recipe.sh" "$recipe" "$@";;
  ping)   "$MONA_DIR/lib/ping.sh" "$@";;
  ssh)    host="$1"; shift; mona_ssh "$host" "$@";;
  gen-cloudinit) "$MONA_DIR/lib/gen_cloudinit.sh" "$@";;
  doctor) "$MONA_DIR/lib/doctor.sh";;
  *) echo "Usage: mona {tui|run|ping|ssh|gen-cloudinit|doctor}"; exit 1;;
esac
```

---

# TUI com `bashsimplecurses` (mini-demo)

```bash
# lib/tui.sh
source "$MONA_DIR/ui/bashsimplecurses/simple_curses.sh"

main() {
  window "MonaRepo — Hosts" "blue" "60%"
    append "Use ↑/↓ e Enter para selecionar; Q para sair."
    addsep
    # renderiza lista do inventário
    while read -r line; do append "$line"; done < <(mona_list_hosts)
  endwin
}

readKey(){ read -rsN1 -t 1 ret && read -t 0.0001 -rsd $'\0' d; echo -n "$ret$d"; }
update(){
  key=$(readKey)
  case "$key" in $'\e[A'|$'\e[B'|$'\n') handle_key "$key";; q|Q) exit 0;; esac
}
main_loop -t 1
```

> `main()` + `main_loop` para desenhar; interação implementada via `update()` e leitura de teclas (`read -rsN1`). ([GitHub][1], [bashsimplecurses.readthedocs.io][2])

---

# cloud-init (primeiro boot)

**templates/cloud-init/user-data.yaml** (exemplo seguro para Ubuntu):

```yaml
#cloud-config
locale: en_US.UTF-8
timezone: Europe/Lisbon
package_update: true
packages: [curl, ca-certificates, git]

write_files:
  - path: /usr/local/sbin/mona-bootstrap.sh
    permissions: '0755'
    content: |
      #!/usr/bin/env bash
      set -euo pipefail
      apt-get update -y
      apt-get install -y bash
      # Clona/atualiza MonaRepo e roda recipe
      repo_dir=/opt/monarepo
      if [ ! -d "$repo_dir/.git" ]; then
        git clone https://github.com/Monynha-Softwares/monarepo "$repo_dir"
      else
        git -C "$repo_dir" pull --ff-only
      fi
      "$repo_dir/bin/mona" run coolify-node

runcmd:
  - [/usr/local/sbin/mona-bootstrap.sh]
```

> `cloud-init` aceita **cloud-config** com `packages`, `write_files` e `runcmd`; é a forma recomendada de injetar configuração/“first boot” em instâncias. ([cloudinit.readthedocs.io][3])

---

# Módulos (exemplos rápidos)

**modules/base/base.sh**

```bash
run_base() {
  mona_pkg install tzdata ufw gnupg lsb-release
  timedatectl set-timezone Europe/Lisbon || true
  # SSH hardening básico
  sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  systemctl reload ssh || systemctl reload sshd || true
  # firewall
  ufw allow OpenSSH; ufw --force enable
}
```

**modules/docker/install.sh**

```bash
run_docker_install() {
  if ! command -v docker >/dev/null; then
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
      gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
       https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo $VERSION_CODENAME) stable" \
      >/etc/apt/sources.list.d/docker.list
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    usermod -aG docker "${SUDO_USER:-$USER}" || true
  fi
}
```

---

# Qualidade, testes e CI

* **ShellCheck** para lint automático dos scripts (pega bugs comuns e más práticas). ([shellcheck.net][4], [GitHub][6])
* **BATS** para testes do CLI/módulos (TAP-compliant, fácil de rodar no CI). ([GitHub][5])

**.github/workflows/ci.yml** (essência):

```yaml
name: CI
on: [push, pull_request]
jobs:
  lint_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: ShellCheck
        run: sudo apt-get update && sudo apt-get install -y shellcheck && shellcheck -x bin/mona modules/**/*.sh lib/**/*.sh
      - name: BATS
        run: |
          git clone https://github.com/bats-core/bats-core /tmp/bats
          sudo /tmp/bats/install.sh /usr/local
          bats -r tests
```

---

# Como usar (MVP)

1. **Adicionar hosts** no `inventory/servers.yml`.
2. **Rodar TUI** local: `./bin/mona tui` → selecione host e receita.
3. **Sem TUI**: `./bin/mona run coolify-node --hosts monynha-online-prod`.
4. **Primeiro-boot** (VM nova): cole `templates/cloud-init/user-data.yaml` no campo **user-data** ao criar a instância (Hetzner/Proxmox-cloud-init, etc.). ([cloudinit.readthedocs.io][7], [documentation.ubuntu.com][8])

---

# Roadmap curtinho

* **Semana 1 (MVP)**: CLI + `base`, `docker`, `coolify`; inventário; TUI simples; cloud-init template; CI com ShellCheck/BATS. (Referências: `bashsimplecurses` uso básico e interação). ([GitHub][1], [bashsimplecurses.readthedocs.io][2])
* **Semana 2**: módulos `wireguard`, `postgres-client`, `monitoring`; *smoke tests* BATS para cada receita. (BATS). ([GitHub][5])
* **Semana 3**: refinamento da TUI (multi-select, logs ao vivo), paralelismo (execução em vários hosts), e **cloud-init** “receitas por papel” (variações de `write_files` + `runcmd`). ([cloudinit.readthedocs.io][9])

---

# Referências 💾🛠️

[1]: https://github.com/metal3d/bashsimplecurses "GitHub - metal3d/bashsimplecurses: A simple curses library made in bash to draw terminal interfaces"
[2]: https://bashsimplecurses.readthedocs.io/en/master/tips/ "Tricks and tips - Bash Simple Curses"
[3]: https://cloudinit.readthedocs.io/en/latest/topics/format.html?utm_source=chatgpt.com "User-data formats - cloud-init 25.2 documentation"
[4]: https://www.shellcheck.net/?utm_source=chatgpt.com "ShellCheck – shell script analysis tool"
[5]: https://github.com/bats-core/bats-core?utm_source=chatgpt.com "bats-core/bats-core: Bash Automated Testing System"
[6]: https://github.com/koalaman/shellcheck?utm_source=chatgpt.com "ShellCheck, a static analysis tool for shell scripts"
[7]: https://cloudinit.readthedocs.io/en/latest/reference/index.html?utm_source=chatgpt.com "Reference - cloud-init 25.2 documentation"
[8]: https://documentation.ubuntu.com/lxd/latest/cloud-init/?utm_source=chatgpt.com "How to use cloud-init"
[9]: https://cloudinit.readthedocs.io/en/latest/reference/examples.html?utm_source=chatgpt.com "All cloud config examples - cloud-init 25.2 documentation"
