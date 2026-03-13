# Contributing

## Local setup

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Main principles

- keep project mutations explicit
- prefer small action classes
- keep route handling readable and testable
- avoid hidden side effects during install and engine generation
- prefer configuration over hardcoded project metadata

## Test expectations

Before opening a pull request, run:

```bash
bundle exec rspec
bundle exec rubocop
```
