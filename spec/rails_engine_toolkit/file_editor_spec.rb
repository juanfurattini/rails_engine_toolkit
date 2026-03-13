# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::FileEditor do
  it 'removes matching lines safely' do
    in_tmpdir do |dir|
      path = dir.join('routes.rb')
      write(path, "a\nb\nc\n")
      changed = described_class.remove_lines_matching(path, /^b$/)
      expect(changed).to be(true)
      expect(path.read).to eq("a\nc\n")
    end
  end

  it 'inserts content after first match' do
    in_tmpdir do |dir|
      path = dir.join('routes.rb')
      write(path, "Rails.application.routes.draw do\nend\n")
      changed = described_class.insert_after_first_match(path, /Rails\.application\.routes\.draw do\s*\n/,
                                                         "  mount Auth::Engine, at: \"/auth\"\n")
      expect(changed).to be(true)
      expect(path.read).to include('mount Auth::Engine, at: "/auth"')
    end
  end
end
