# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::CLI do
  it 'shows help for unknown commands' do
    expect do
      described_class.start(['unknown'])
    end.to output(/Commands:/).to_stdout
  end
end
