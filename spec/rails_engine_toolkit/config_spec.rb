# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::Config do
  it 'loads valid configuration' do
    in_tmpdir do |dir|
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

      config = described_class.load(dir)
      expect(config.project_name).to eq('Transport System')
      expect(config.project_slug).to eq('transport_system')
    end
  end

  it 'rejects invalid database adapter' do
    in_tmpdir do |dir|
      write(dir.join('config/engine_toolkit.yml'), <<~YAML)
        project:
          name: "Transport System"
          slug: "transport_system"
          url: ""
        author:
          name: "Juan"
          email: "juan@example.com"
        defaults:
          database: "oracle"
        metadata:
          license: "MIT"
      YAML

      expect { described_class.load(dir) }.to raise_error(RailsEngineToolkit::ValidationError, /defaults.database/)
    end
  end
end
