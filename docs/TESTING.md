# Testing strategy

## Layers

The test suite is split into four layers:

1. focused specs for utility classes and file mutation helpers
2. action specs that exercise CLI-facing workflows on temporary directories
3. integration-style specs for route insertion, removal, and migration installation/uninstallation
4. host-app smoke checks through CI using a Rails 8.1 fixture app

## Main scenarios covered

- install generator creates configuration and prints summary
- broken engine references in Gemfile are detected and can be removed
- route mounts are inspected with parser-assisted detection
- route mounts are inserted once and removed across multiple mount syntaxes
- engine README owned tables are updated from engine migrations
- engine migration files can be installed into the host app one engine at a time
- copied root migrations can be uninstalled with explicit confirmation
- engine removal cleans routes, Gemfile, and engine directory
