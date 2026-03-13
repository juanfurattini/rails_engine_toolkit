# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::RoutesRewriter do
  it 'adds a mount only once' do
    in_tmpdir do |dir|
      path = dir.join('config/routes.rb')
      write(path, "Rails.application.routes.draw do\nend\n")

      rewriter = described_class.new(path)
      expect(rewriter.add_mount(engine_class: 'Auth', mount_path: '/auth')).to be(true)
      expect(rewriter.add_mount(engine_class: 'Auth', mount_path: '/auth')).to be(false)

      content = path.read
      expect(content.scan('mount Auth::Engine, at: "/auth"').size).to eq(1)
    end
  end

  it 'removes all supported mount variants for one engine path' do
    in_tmpdir do |dir|
      path = dir.join('config/routes.rb')
      write(path, <<~RUBY)
        Rails.application.routes.draw do
          mount Auth::Engine, at: "/auth"
          mount(Auth::Engine, at: "/auth")
          mount Auth::Engine => "/auth"
        end
      RUBY

      rewriter = described_class.new(path)
      expect(rewriter.remove_mount(engine_class: 'Auth', mount_path: '/auth')).to be(true)
      expect(path.read).not_to include('mount Auth::Engine')
    end
  end
end
