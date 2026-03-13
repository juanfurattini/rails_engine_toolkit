# Architecture

## Main components

- `CLI`: command entrypoint powered by Thor
- `Project`: host app path and mutation helper
- `Config`: validated project configuration loader
- `FileEditor`: small safe file mutation helpers
- `Templates`: ERB renderer for generated content
- `Actions::*`: business operations

## Rails integration

The gem ships a Railtie and a generator:

- `rails generate engine_toolkit:install`

That keeps the install experience close to tools such as `rspec:install`. The install generator creates the configuration file and prints a summary plus the exact path to edit.
