# frozen_string_literal: true

require 'yaml'
require 'erb'
require 'pathname'
require 'fileutils'
require 'thor'
require 'ripper'

require_relative 'rails_engine_toolkit/version'
require_relative 'rails_engine_toolkit/errors'
require_relative 'rails_engine_toolkit/utils'
require_relative 'rails_engine_toolkit/config'
require_relative 'rails_engine_toolkit/file_editor'
require_relative 'rails_engine_toolkit/route_inspector'
require_relative 'rails_engine_toolkit/routes_rewriter'
require_relative 'rails_engine_toolkit/project'
require_relative 'rails_engine_toolkit/templates'
require_relative 'rails_engine_toolkit/actions/init'
require_relative 'rails_engine_toolkit/actions/new_engine'
require_relative 'rails_engine_toolkit/actions/update_engine_readme'
require_relative 'rails_engine_toolkit/actions/new_engine_migration'
require_relative 'rails_engine_toolkit/actions/delete_engine_migration'
require_relative 'rails_engine_toolkit/actions/new_engine_model'
require_relative 'rails_engine_toolkit/actions/install_engine_migrations'
require_relative 'rails_engine_toolkit/actions/uninstall_engine_migrations'
require_relative 'rails_engine_toolkit/actions/remove_engine'
require_relative 'rails_engine_toolkit/cli'

module RailsEngineToolkit
end

require_relative 'rails_engine_toolkit/railtie' if defined?(Rails::Railtie)
