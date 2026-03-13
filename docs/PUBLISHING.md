# Publishing

## Publish to RubyGems

Create an account on RubyGems.org, then:

```bash
gem build rails_engine_toolkit.gemspec
gem push rails_engine_toolkit-0.6.2.gem
```

Consumers can then use:

```ruby
gem "rails_engine_toolkit"
```

instead of `github:` or `path:`.

## Trusted publishing

You can also set up GitHub Actions with trusted publishing so that releases push automatically after tagging.

See the RubyGems publishing guide and trusted publishing guide.
