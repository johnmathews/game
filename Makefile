.PHONY: lint-python lint-python-fix lint-gdscript lint test-backend test-godot test coverage coverage-html

lint-python:
	cd backend && uv run ruff check .

lint-python-fix:
	cd backend && uv run ruff check --fix .

lint-gdscript:
	gdlint godot/

lint: lint-python lint-gdscript

test-backend:
	cd backend && uv run pytest -v

test-godot:
	# Requires Godot headless + GUT plugin installed
	# Example: godot --headless --script addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json

test: test-backend

coverage:
	cd backend && uv run coverage run -m pytest && uv run coverage report

coverage-html:
	cd backend && uv run coverage run -m pytest && uv run coverage html
