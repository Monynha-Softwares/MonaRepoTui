SHELL := /bin/bash

.PHONY: install-dev fmt lint test ci

install-dev:
	sudo apt-get update -y
	sudo apt-get install -y shellcheck shfmt bats curl
	pip install --upgrade pre-commit editorconfig-checker
	pre-commit install --install-hooks
	pre-commit install --hook-type pre-push --install-hooks

fmt:
	shfmt -w bin modules recipes tests

lint:
	bash -O globstar -c 'shellcheck -x bin/mona modules/**/*.sh'
	shfmt -d bin modules recipes tests

test:
	bats -r tests

ci: lint test
