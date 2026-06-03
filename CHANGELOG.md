# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-06-04

### Changed

- `Respawn::Environment` no longer enumerates a fixed list of environments.
  It now exposes only `#test?` and `#other?`, so any environment name
  (e.g. `staging`) is accepted instead of being rejected. This matches the
  only distinction the gem actually relies on (test vs. not-test).
- `Environment.default` now also reads `RACK_ENV`, falling back through
  `RUBY_ENV` → `RAILS_ENV` → `RACK_ENV` → `"production"`.

### Removed

- **Breaking:** The `ENVIRONMENTS` allowlist and the per-environment
  predicates (`#development?`, `#production?`). Constructing an `Environment`
  with an unknown name no longer raises `ArgumentError`.
