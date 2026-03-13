# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::Project do
  it 'detects broken engine references from Gemfile' do
    in_tmpdir do |dir|
      write(dir.join('Gemfile'), <<~RUBY)
        source "https://rubygems.org"
        gem "auth", path: "engines/auth"
        gem "billing", path: "engines/billing"
      RUBY
      FileUtils.mkdir_p(dir.join('engines/auth'))

      project = described_class.new(dir)
      expect(project.broken_engine_references).to eq(['billing'])
    end
  end
end
