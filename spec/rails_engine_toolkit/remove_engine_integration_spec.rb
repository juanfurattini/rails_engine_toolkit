# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::Actions::RemoveEngine do
  def build_project(dir, routes_content:)
    write(dir.join('Gemfile'), <<~RUBY)
      source "https://rubygems.org"
      gem "auth", path: "engines/auth"
    RUBY
    write(dir.join('config/routes.rb'), routes_content)
    write(dir.join('engines/auth/README.md'), "# Auth\n")
  end

  it 'removes all supported mount variants when present in multiple lines' do
    in_tmpdir do |dir|
      build_project(dir, routes_content: <<~RUBY)
        Rails.application.routes.draw do
          mount Auth::Engine, at: "/auth"
          mount(Auth::Engine, at: "/auth")
          mount Auth::Engine => "/auth"
        end
      RUBY

      input = StringIO.new("auth\n")
      output = StringIO.new
      action = described_class.new(['auth'], stdin: input, stdout: output, stderr: StringIO.new, root: dir)
      allow(RailsEngineToolkit::Utils).to receive(:safe_system).and_return(true)

      action.call

      routes = dir.join('config/routes.rb').read
      expect(routes).not_to include('mount Auth::Engine, at: "/auth"')
      expect(routes).not_to include('mount(Auth::Engine, at: "/auth")')
      expect(routes).not_to include('mount Auth::Engine => "/auth"')
      expect(dir.join('engines/auth')).not_to exist
      expect(dir.join('Gemfile').read).not_to include('path: "engines/auth"')
    end
  end
end
