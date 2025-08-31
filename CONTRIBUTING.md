# Contributing

Thank you for considering contributing!

## Development setup

```bash
make install-dev
```

## Style & tests

* Format: `make fmt`
* Lint: `make lint`
* Test: `make test`
* Version bumps: update the version in `README.md` and keep `tests/version.bats` in sync with `./bin/mona --version`.

Please run the above before submitting a PR.

See [docs/contributing.md](docs/contributing.md) for more details.
