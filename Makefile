CURRENT_VERSION = $(shell cat version.txt)

.PHONY: all speedups-install install dev-install build new-release new-tag delete-tag new-version clean tests

all: | build speedups-install

build:
	cd compiler/api && poetry run python compiler.py
	cd compiler/errors && poetry run python compiler.py
	poetry build

speedups-install:
	poetry install -E speedups

install:
	poetry install

dev-install:
	poetry install --with dev

publish: | build
	poetry publish

new-tag:
	git tag $(CURRENT_VERSION)
	git push origin $(CURRENT_VERSION)

delete-tag:
	git tag -d $(CURRENT_VERSION)
	git push origin -d $(CURRENT_VERSION)

new-release: | publish new-tag

new-version:
	sed -E 's/^"(\w|\d|\.)+"/"${V}"/' -i version.txt
	sed -E 's/version = "(\w|\d|\.)+"/version = "${V}"/' -i pyproject.toml
	sed -E 's/__version__ = "(\w|\d|\.)+"/__version__ = "${V}"/' -i pyrogram/__init__.py

clean:
	rm -rf pyrogram/errors/exceptions \
		pyrogram/raw/all.py \
		pyrogram/raw/base \
		pyrogram/raw/functions \
		pyrogram/raw/types

tests:
	poetry run tox
