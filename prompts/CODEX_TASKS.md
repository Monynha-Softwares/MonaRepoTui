# Codex Tasks Prompt (Drop-in)

You are an autonomous coding agent working on the MonaRepo project.
Follow these rules:
- Keep changes small and incremental with clear commit messages.
- Write or update tests (BATS) for every change.
- Do not break interactive TUI usage in `bin/mona`.
- Respect `--dry-run` behavior.

## Tasks
- [ ] Extract helpers to `lib/*.sh` and update imports in `bin/mona`.
- [ ] Implement `lib/yaml.sh` lightweight parser or integrate `yq` if available.
- [ ] Add `modules/coolify/bootstrap.sh` with detection and safe idempotent actions.
- [ ] Add `recipes/supabase-node.sh` using modules: base, docker.
- [ ] Add `tests/modules_base.bats` and `tests/modules_docker.bats` with smoke checks.
- [ ] Enhance `flow_run_recipe` to support params `--set key=value` forwarding to recipes.
- [ ] Add `docs/` with architecture diagram and usage screenshots.


Eu gostaria que houvesse uma opção em que o usuario pudesse escolher o tipo de instaçacao do programada (a partir de um repositorio github, docker etc), ele fornecesse a fonte do recursos, ou fosse listadas por exemplos os repositorios disponiveis piublicos da minya softwares, depois o programa baixasse a fonte, lesse o projeto, por exemplo, exibindo o readme para o usuario e depois perguntando o que pretendia fazer (por exemplo, copiar e editar arquivo .env.example, executar um script etc..) e que o programa fosse acompnhando a instalaçao do usuario, como um wrapper.