SHELL := /bin/bash

.PHONY: lint test ci

lint:
	@command -v shellcheck >/dev/null || { echo 'Install shellcheck'; exit 1; }
	shellcheck -x bin/mona modules/**/*.sh || true

test:
	@command -v bats >/dev/null || { echo 'Install bats-core'; exit 1; }
	bats -r tests

ci: lint test
