# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsEngineToolkit::Actions::InstallEngineMigrations do
  it 'copies only the selected engine migrations into root db/migrate' do
    in_tmpdir do |dir|
      write(dir.join('Gemfile'), "source \"https://rubygems.org\"\n")
      write(dir.join('engines/auth/db/migrate/20260101000000_create_auth_credentials.rb'),
            'class CreateAuthCredentials; end')
      write(dir.join('engines/billing/db/migrate/20260101000001_create_billing_invoices.rb'),
            'class CreateBillingInvoices; end')

      out = StringIO.new
      described_class.new(['auth'], stdin: StringIO.new, stdout: out, stderr: StringIO.new, root: dir).call

      root_migrations = dir.join('db/migrate').glob('*.rb').map { |f| f.basename.to_s }
      expect(root_migrations.any? { |name| name.end_with?('create_auth_credentials.rb') }).to be(true)
      expect(root_migrations.any? { |name| name.end_with?('create_billing_invoices.rb') }).to be(false)
    end
  end

  it 'does not duplicate already installed migrations' do
    in_tmpdir do |dir|
      write(dir.join('Gemfile'), "source \"https://rubygems.org\"\n")
      write(dir.join('engines/auth/db/migrate/20260101000000_create_auth_credentials.rb'),
            'class CreateAuthCredentials; end')
      write(dir.join('db/migrate/20260102000000_create_auth_credentials.rb'), 'class CreateAuthCredentials; end')

      out = StringIO.new
      described_class.new(['auth'], stdin: StringIO.new, stdout: out, stderr: StringIO.new, root: dir).call

      expect(out.string).to include('No new migrations')
    end
  end
end
