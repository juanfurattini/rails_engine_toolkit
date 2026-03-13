# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::Actions::UpdateEngineReadme do
  it 'updates owned tables using migrations only' do
    in_tmpdir do |dir|
      write(dir.join('Gemfile'), "source \"https://rubygems.org\"\n")
      write(dir.join('engines/auth/README.md'), <<~MD)
        # Auth

        ## Owned tables
        - None defined yet.

        ## Public endpoints
        - None defined yet.
      MD
      write(dir.join('engines/auth/db/migrate/20260101000000_create_auth_credentials.rb'), <<~RB)
        class CreateAuthCredentials < ActiveRecord::Migration[8.1]
          def change
            create_table :auth_credentials do |t|
            end
          end
        end
      RB

      described_class.new(['auth'], stdin: StringIO.new, stdout: StringIO.new, stderr: StringIO.new, root: dir).call

      expect(dir.join('engines/auth/README.md').read).to include('- auth_credentials')
    end
  end
end
