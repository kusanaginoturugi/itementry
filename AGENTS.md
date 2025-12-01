# Repository Guidelines

## Project Structure & Module Organization
- `app/` holds Rails code: controllers, models, views, Stimulus/Turbo front-end, and jobs/mailers if added.  
- `config/` contains environment, routes, and CI config (`config/ci.rb`).  
- `db/` stores migrations and schema; use fixtures in `test/fixtures/` for data.  
- `test/` includes unit/integration suites plus `test/system/` for browser-driven checks.  
- `bin/` scripts wrap common tasks (`bin/rails`, `bin/ci`, `bin/setup`); prefer these over raw commands.

## Build, Test, and Development Commands
- Initial setup: `bin/setup` (installs gems, prepares database, clears logs; add `--reset` to rebuild the DB).  
- Run app locally: `bin/dev` (starts `bin/rails server`).  
- Database prep if needed: `bin/rails db:prepare`.  
- Full CI locally: `bin/ci` (runs setup, lint, security scans, tests, seeds).  
- Quick tasks: `bin/rake -T` to list available Rake tasks.

## Coding Style & Naming Conventions
- Ruby style enforced via `bin/rubocop` using `rubocop-rails-omakase`; favor 2-space indentation, single quotes unless interpolation, and short methods.  
- Rails naming: classes are `CamelCase`, files `snake_case.rb`; tests end with `_test.rb`.  
- Keep controllers thin and move business rules to models/service objects in `app/` or `app/lib` if added.  
- Front-end Stimulus controllers live in `app/javascript/controllers`; name with hyphenated filenames (`example_controller.js`).

## Testing Guidelines
- Primary framework: Minitest via `bin/rails test`; system/browser specs via `bin/rails test:system`.  
- Run seed integrity check: `env RAILS_ENV=test bin/rails db:seed:replant` (already included in `bin/ci`).  
- Add tests alongside code changes; fixtures should be minimal and deterministic.  
- Prefer descriptive test method names (`test_handles_empty_inventory`) and ensure idempotent setup/teardown.

## Security & Quality Checks
- Security scans: `bin/bundler-audit` for gem advisories, `bin/importmap audit` for JS, and `bin/brakeman --quiet` for Rails code risks.  
- CI script orders checks before tests; match that locally to catch issues early.  
- Avoid committing secrets; use environment variables and keep `.env`-style files out of Git.

## Commit & Pull Request Guidelines
- Commit messages: short, imperative summaries (e.g., `Add item import job`). Split changes into logical commits.  
- Before opening a PR: run `bin/ci` and include context (goal, approach, risks), linked issues, and screenshots/console output for UI or system changes.  
- Highlight migrations or data changes explicitly and note any manual steps (`bin/rails db:migrate`, backfills).
