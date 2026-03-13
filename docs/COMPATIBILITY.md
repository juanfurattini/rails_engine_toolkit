# Compatibility strategy

## Rails support

The gem is intended to support Rails 8.1.x first.

## Verification approach

Compatibility is checked at four levels:

1. unit specs
2. integration-style specs on temporary directories
3. install generator smoke test in a dummy host app fixture
4. CI matrix across supported Ruby and Rails versions

## Important limitation

A true dynamic matrix that creates full temporary Rails apps at runtime is possible, but is best executed in CI rather than lightweight local scaffolding environments.
