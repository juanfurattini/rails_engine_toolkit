# Release workflow

## Local release

1. Update `lib/rails_engine_toolkit/version.rb`
2. Commit your changes
3. Tag the release
4. Build and push the gem

```bash
gem build rails_engine_toolkit.gemspec
gem push rails_engine_toolkit-0.3.0.gem
git tag v0.3.0
git push origin v0.3.0
```

## GitHub Actions release

This repository includes a RubyGems release workflow template.

### Required secret

- `RUBYGEMS_API_KEY`

### Trigger

Push a version tag such as:

```bash
git tag v0.3.0
git push origin v0.3.0
```
