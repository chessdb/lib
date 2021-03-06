
.PHONY: install hooks lint install test fix clean help

PLATFORM?=local
TMP_HOOKS:=/tmp/.chessdb_lib_hooks_empty.target
VERSION:=src/chessdb_lib/version.py

.DEFAULT:help
help:
	@printf "The following commands are available:\n\n"
	@printf "\e[92m%s\e[0m\n" "make hooks"
	@echo " - setup pre-commit hooks"
	@printf "\e[92m%s\e[0m\n" "make test"
	@echo " - run tests"
	@printf "\e[92m%s\e[0m\n" "make lint"
	@echo " - Autoformats code and sorts imports (unless running as 'ci')."
	@printf "\e[92m%s\e[0m\n" "make run"
	@echo " - runs chessdb_lib"

${VERSION}:
	@echo "__version__ = \"$(shell git describe --always)\"" > ${VERSION}

hooks:${TMP_HOOKS}
${TMP_HOOKS}:.pre-commit-config.yaml
	@pip install pre-commit > /dev/null
	@pre-commit install > /dev/null
	@pre-commit run --all-files || \
		(printf "\e[93m%s\e[0m\n" "Run same make target again";exit 1)
	@printf "\e[92m%s\e[0m\n" "Pre-commit hooks ran successfully"
	@touch /tmp/.chessdb_lib_hooks_empty_target

lint:
	@pip install yapf pylint 'isort<5.0'
	@yapf --style google -dpr src tests
	@pylint --rcfile=setup.cfg -r n src tests > pylint.txt

install: ${VERSION}
	@python3 setup.py develop

test: install
	@python3 setup.py test

fix: hooks
	@pip install yapf pylint 'isort<5.0'
	@isort --recursive src tests
	@yapf --style google -ipr src tests
	@pylint --rcfile=setup.cfg src tests

clean:
	@find src tests | grep -E "(__pycache__|\.pyc)" | xargs rm -rf
	@rm -rf \
		src/chessdb_lib.egg-info/ \
		.eggs/ \
		.coverage \
		htmlcov/ \
		dist/ \
		build/ \
		coverage.xml \
		pylint.txt
