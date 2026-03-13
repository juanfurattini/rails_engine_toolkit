# frozen_string_literal: true

require 'spec_helper'
require 'rails_engine_toolkit/generators/install/install_generator'

RSpec.describe RailsEngineToolkit::Generators::InstallGenerator do
  it 'creates config and prints summary in a host app' do
    in_tmpdir do |dir|
      write(dir.join('Gemfile'), "source \"https://rubygems.org\"\n")

      generator = described_class.new
      allow(generator).to receive(:destination_root).and_return(dir.to_s)
      allow(generator).to receive(:ask).and_return('', '', '', '', '', 'postgresql')
      allow(generator).to receive(:yes?).and_return(true, true, true, true)
      output = StringIO.new
      allow(generator).to receive(:say) { |message = '', *_args| output.puts(message) }
      allow(generator).to receive(:say_status) { |_status, message, *_args| output.puts(message) }

      generator.create_config_file

      expect(dir.join('config/engine_toolkit.yml')).to exist
      expect(output.string).to include('Default configuration created:')
      expect(output.string).to include('config/engine_toolkit.yml')
    end
  end
end
