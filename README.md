# Rails Engine Toolkit

Reusable tooling for Rails projects that use internal engines.

## What this gem provides

- `rails generate engine_toolkit:install`
- `engine-toolkit init`
- `engine-toolkit new_engine ENGINE_NAME`
- `engine-toolkit new_engine_model ENGINE_NAME MODEL_NAME [ATTRS...]`
- `engine-toolkit new_engine_migration ENGINE_NAME MIGRATION_NAME [ATTRS...]`
- `engine-toolkit install_engine_migrations ENGINE_NAME`
- `engine-toolkit uninstall_engine_migrations ENGINE_NAME`
- `engine-toolkit delete_engine_migration ENGINE_NAME PATTERN`
- `engine-toolkit update_engine_readme ENGINE_NAME`
- `engine-toolkit remove_engine ENGINE_NAME`

## What is new in v6.3

- RuboCop cleanup and sane project-level RuboCop configuration
- action classes split into smaller private helpers where useful
- long lines and unused arguments fixed
- packaging polish for a cleaner public repository

## Installation in a host Rails app

```ruby
gem "rails_engine_toolkit"
```

Then:

```bash
bundle install
bin/rails generate engine_toolkit:install
```

The install generator creates:

```text
config/engine_toolkit.yml
```

and prints:

- the generated default configuration
- the full path of the file you should edit

## CLI usage

```bash
bundle exec engine-toolkit new_engine auth
bundle exec engine-toolkit new_engine_model auth credential email:string
bundle exec engine-toolkit new_engine_migration auth CreateCredentials
bundle exec engine-toolkit install_engine_migrations auth
bundle exec engine-toolkit uninstall_engine_migrations auth
bundle exec engine-toolkit update_engine_readme auth
bundle exec engine-toolkit delete_engine_migration auth create_credentials
bundle exec engine-toolkit remove_engine auth
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Publishing to RubyGems

```bash
gem build rails_engine_toolkit.gemspec
gem push rails_engine_toolkit-0.6.4.gem
```

After it is published, consumers can install it with:

```ruby
gem "rails_engine_toolkit"
```

without `github:` or `path:`.
