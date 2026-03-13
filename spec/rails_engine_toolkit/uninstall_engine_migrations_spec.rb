# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::Actions::UninstallEngineMigrations do
  it 'removes copied root migration files matching one engine' do
    in_tmpdir do |dir|
      write(dir.join('Gemfile'), "source \"https://rubygems.org\"\n")
      write(dir.join('engines/auth/db/migrate/20260101000000_create_auth_credentials.rb'),
            'class CreateAuthCredentials; end')
      root_file = dir.join('db/migrate/20260102000000_create_auth_credentials.rb')
      write(root_file, 'class CreateAuthCredentials; end')

      input = StringIO.new("auth\n")
      out = StringIO.new
      described_class.new(['auth'], stdin: input, stdout: out, stderr: StringIO.new, root: dir).call

      expect(root_file).not_to exist
      expect(out.string).to include('does NOT rollback the database automatically')
    end
  end

  it 'does nothing when there are no installed root migrations for that engine' do
    in_tmpdir do |dir|
      write(dir.join('Gemfile'), "source \"https://rubygems.org\"\n")
      write(dir.join('engines/auth/db/migrate/20260101000000_create_auth_credentials.rb'),
            'class CreateAuthCredentials; end')

      out = StringIO.new
      described_class.new(['auth'], stdin: StringIO.new, stdout: out, stderr: StringIO.new, root: dir).call

      expect(out.string).to include('No installed root migrations found')
    end
  end
end
