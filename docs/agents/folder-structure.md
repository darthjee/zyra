# Folder Structure

## Project Root

| Directory / File | Description |
|---|---|
| `lib/` | Gem source code (`zyra.rb` entry point and `zyra/` namespace). |
| `spec/` | RSpec suite: unit specs, integration specs, and shared support. |
| `config/` | Tooling configuration (spec-coverage check, yardstick, rubycritic). |
| `docs/agents/` | Documentation for agents: architecture, flow, issues, plans. |
| `.circleci/` | CI pipeline and release configuration. |
| `.github/` | PR/commit templates and Copilot instructions. |
| `Dockerfile`, `Dockerfile.circleci`, `docker-compose.yml`, `Makefile` | Docker-based dev/test environment. |
| `zyra.gemspec`, `Gemfile`, `Rakefile` | Gem packaging, dependencies and tasks. |
| `.rubocop.yml`, `.rubocop_todo.yml`, `.rspec` | Lint and test runner configuration. |
| `README.md`, `zyra.jpg`, `LICENSE` | Public docs, logo, license. |
| `AGENTS.md`, `CLAUDE.md` | Shared agent instructions (CLAUDE.md points to AGENTS.md). |

## spec/

| Subdirectory | Description |
|---|---|
| `lib/` | Unit specs mirroring `lib/`. |
| `integration/` | Specs validating README and YARD examples. |
| `support/` | Factories, models, schema and shared examples. |

## config/

| File | Description |
|---|---|
| `check_specs.yml` | Files ignored by the "every file has a spec" check. |
| `yardstick.rb`, `yardstick.yml` | YARD documentation coverage checks. |
| `rubycritc.rb` | Rubycritic config. |
