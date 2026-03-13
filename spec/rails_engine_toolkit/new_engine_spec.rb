# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::Actions::NewEngine do
  it 'asks to remove broken engine references before creating a new engine' do
    in_tmpdir do |dir|
      write(dir.join('Gemfile'), <<~RUBY)
        source "https://rubygems.org"
        gem "missing", path: "engines/missing"
      RUBY
      write(dir.join('config/routes.rb'), "Rails.application.routes.draw do\nend\n")
      write(dir.join('config/engine_toolkit.yml'), <<~YAML)
        project:
          name: "Transport System"
          slug: "transport_system"
          url: "https://example.test/repo"
        author:
          name: "Juan"
          email: "juan@example.com"
        defaults:
          database: "postgresql"
          api_only: true
          mount_routes: true
          create_ddd_structure: true
        metadata:
          license: "MIT"
          ruby_version: ">= 3.2"
          rails_version: ">= 8.1.2"
      YAML

      input = StringIO.new("y\n\n")
      output = StringIO.new
      action = described_class.new(['auth'], stdin: input, stdout: output, stderr: StringIO.new, root: dir)

      allow(RailsEngineToolkit::Utils).to receive(:safe_system) do |*args, **_kwargs|
        if args[0..4] == %w[bundle exec rails plugin new]
          FileUtils.mkdir_p(dir.join('engines/auth/lib/auth'))
          FileUtils.mkdir_p(dir.join('engines/auth'))
          write(dir.join('engines/auth/Gemfile'), '')
          write(dir.join('engines/auth/auth.gemspec'), '')
          write(dir.join('engines/auth/MIT-LICENSE'), '')
          write(dir.join('engines/auth/README.md'), '')
        end
        true
      end

      action.call

      expect(dir.join('Gemfile').read).not_to include('path: "engines/missing"')
      expect(dir.join('config/routes.rb').read).to include('mount Auth::Engine, at: "/auth"')
    end
  end
end
