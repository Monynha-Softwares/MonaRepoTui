SHELL := /bin/bash

.PHONY: install-dev fmt lint test

install-dev:
	sudo apt-get update -y
	sudo apt-get install -y shellcheck shfmt bats curl
	pip install --upgrade pre-commit
	pre-commit install --install-hooks

fmt:
	shfmt -w bin modules recipes tests

lint:
	shellcheck -x bin/mona modules/**/*.sh
	shfmt -d bin modules recipes tests

test:
	bats -r tests
