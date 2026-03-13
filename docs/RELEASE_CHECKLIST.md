# Release checklist

## Before releasing

- Run the test suite:

```bash
bundle exec rspec
```

- Run the linter:

```bash
bundle exec rubocop
```

- Verify the gem builds:

```bash
gem build rails_engine_toolkit.gemspec
```

- Review:
  - `README.md`
  - `docs/PUBLISHING.md`
  - `docs/RELEASE.md`
  - `lib/rails_engine_toolkit/version.rb`

## Release steps

1. Bump the version in `lib/rails_engine_toolkit/version.rb`
2. Commit the changes
3. Tag the release
4. Push the tag
5. Publish the gem manually or through GitHub Actions

## Manual publish

```bash
gem build rails_engine_toolkit.gemspec
gem push rails_engine_toolkit-0.6.2.gem
```

## Tag example

```bash
git tag v0.6.2
git push origin v0.6.2
```
