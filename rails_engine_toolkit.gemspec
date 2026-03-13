# frozen_string_literal: true

require_relative 'lib/rails_engine_toolkit/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails_engine_toolkit'
  spec.version       = RailsEngineToolkit::VERSION
  spec.authors       = ['Juan Furattini']
  spec.email         = ['juan.furattini@gmail.com']

  spec.summary       = 'Reusable CLI and generators for Rails engines'
  spec.description   =
    'Creates and manages internal Rails engines with configurable conventions, safe file mutations, parser-assisted route inspection, engine-specific migration installation, and Rails install generators.'
  spec.homepage      = 'https://github.com/juanfurattini/rails_engine_toolkit'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.glob('{exe,lib,spec,test,docs,.github}/**/*') +
               %w[README.md LICENSE.txt rails_engine_toolkit.gemspec Gemfile Rakefile]
  spec.bindir = 'exe'
  spec.executables = ['engine-toolkit']
  spec.require_paths = ['lib']

  spec.add_dependency 'railties', '>= 8.1.0'
  spec.add_dependency 'thor', '>= 1.3'
end
