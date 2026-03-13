# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::Actions::NewEngine do
  def config_yaml
    <<~YAML
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
  end

  it 'inserts the mount line only once and creates DDD folders' do
    in_tmpdir do |dir|
      write(dir.join('Gemfile'), "source \"https://rubygems.org\"\n")
      write(dir.join('config/routes.rb'), "Rails.application.routes.draw do\nend\n")
      write(dir.join('config/engine_toolkit.yml'), config_yaml)

      input = StringIO.new("\n")
      output = StringIO.new
      action = described_class.new(['auth'], stdin: input, stdout: output, stderr: StringIO.new, root: dir)

      allow(RailsEngineToolkit::Utils).to receive(:safe_system) do |*args, **_kwargs|
        if args[0..4] == %w[bundle exec rails plugin new]
          FileUtils.mkdir_p(dir.join('engines/auth'))
          FileUtils.mkdir_p(dir.join('engines/auth/lib/auth'))
          write(dir.join('engines/auth/Gemfile'), '')
          write(dir.join('engines/auth/auth.gemspec'), '')
          write(dir.join('engines/auth/MIT-LICENSE'), '')
          write(dir.join('engines/auth/README.md'), '')
        end
        true
      end

      action.call

      routes = dir.join('config/routes.rb').read
      expect(routes.scan('mount Auth::Engine, at: "/auth"').size).to eq(1)

      expect(dir.join('engines/auth/app/use_cases')).to exist
      expect(dir.join('engines/auth/app/services')).to exist
      expect(dir.join('engines/auth/app/policies')).to exist
    end
  end
end
