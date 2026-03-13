# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::Actions::RemoveEngine do
  def build_action(dir, routes_content:)
    write(dir.join('Gemfile'), <<~RUBY)
      source "https://rubygems.org"
      gem "auth", path: "engines/auth"
    RUBY
    write(dir.join('config/routes.rb'), routes_content)
    write(dir.join('engines/auth/README.md'), "# Auth\n")

    described_class.new(
      ['auth'],
      stdin: StringIO.new("auth\n"),
      stdout: StringIO.new,
      stderr: StringIO.new,
      root: dir
    )
  end

  it 'removes standard mount lines' do
    in_tmpdir do |dir|
      routes_content = <<~RUBY
        Rails.application.routes.draw do
          mount Auth::Engine, at: "/auth"
        end
      RUBY
      action = build_action(dir, routes_content: routes_content)
      allow(RailsEngineToolkit::Utils).to receive(:safe_system)

      action.call

      expect(dir.join('config/routes.rb').read).not_to include('mount Auth::Engine, at: "/auth"')
      expect(dir.join('Gemfile').read).not_to include('path: "engines/auth"')
      expect(dir.join('engines/auth')).not_to exist
    end
  end

  it 'removes hash rocket mount lines' do
    in_tmpdir do |dir|
      routes_content = <<~RUBY
        Rails.application.routes.draw do
          mount Auth::Engine => "/auth"
        end
      RUBY
      action = build_action(dir, routes_content: routes_content)
      allow(RailsEngineToolkit::Utils).to receive(:safe_system)

      action.call

      expect(dir.join('config/routes.rb').read).not_to include('mount Auth::Engine => "/auth"')
    end
  end

  it 'removes parenthesized mount lines' do
    in_tmpdir do |dir|
      routes_content = <<~RUBY
        Rails.application.routes.draw do
          mount(Auth::Engine, at: "/auth")
        end
      RUBY
      action = build_action(dir, routes_content: routes_content)
      allow(RailsEngineToolkit::Utils).to receive(:safe_system)

      action.call

      expect(dir.join('config/routes.rb').read).not_to include('mount(Auth::Engine, at: "/auth")')
    end
  end
end
