# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::RouteInspector do
  it 'detects supported mount variants' do
    content = <<~RUBY
      Rails.application.routes.draw do
        mount Auth::Engine, at: "/auth"
        mount(Auth::Engine, at: "/auth")
        mount Auth::Engine => "/auth"
      end
    RUBY

    inspector = described_class.new(content)
    expect(inspector.syntax_valid?).to be(true)
    expect(inspector.mounts.size).to eq(3)
    expect(inspector.includes_mount?('Auth', '/auth')).to be(true)
  end
end
