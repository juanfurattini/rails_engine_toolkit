# frozen_string_literal: true

module RailsEngineToolkit
  class CLI < Thor
    class_option :root, type: :string

    KNOWN_COMMANDS = %w[
      help
      init
      new_engine
      update_engine_readme
      new_engine_migration
      delete_engine_migration
      new_engine_model
      install_engine_migrations
      uninstall_engine_migrations
      remove_engine
    ].freeze

    def self.exit_on_failure?
      true
    end

    desc 'init', 'Create config/engine_toolkit.yml'
    def init
      run_action(Actions::Init, [])
    end

    desc 'new_engine ENGINE_NAME', 'Create a new internal Rails engine'
    def new_engine(engine_name)
      run_action(Actions::NewEngine, [engine_name])
    end

    desc 'update_engine_readme ENGINE_NAME', 'Refresh the README owned tables section'
    def update_engine_readme(engine_name)
      run_action(Actions::UpdateEngineReadme, [engine_name])
    end

    desc 'new_engine_migration ENGINE_NAME MIGRATION_NAME [ARGS...]', 'Create a migration inside an engine'
    def new_engine_migration(engine_name, migration_name, *args)
      run_action(Actions::NewEngineMigration, [engine_name, migration_name, *args])
    end

    desc 'delete_engine_migration ENGINE_NAME PATTERN', 'Delete matching engine migration files'
    def delete_engine_migration(engine_name, pattern)
      run_action(Actions::DeleteEngineMigration, [engine_name, pattern])
    end

    desc 'new_engine_model ENGINE_NAME MODEL_NAME [ATTRS...]', 'Create a model inside an engine'
    def new_engine_model(engine_name, model_name, *attrs)
      run_action(Actions::NewEngineModel, [engine_name, model_name, *attrs])
    end

    desc 'install_engine_migrations ENGINE_NAME', "Copy only one engine's migrations into the host app"
    def install_engine_migrations(engine_name)
      run_action(Actions::InstallEngineMigrations, [engine_name])
    end

    desc 'uninstall_engine_migrations ENGINE_NAME', 'Remove root migrations that were installed from one engine'
    def uninstall_engine_migrations(engine_name)
      run_action(Actions::UninstallEngineMigrations, [engine_name])
    end

    desc 'remove_engine ENGINE_NAME', 'Remove an internal engine'
    def remove_engine(engine_name)
      run_action(Actions::RemoveEngine, [engine_name])
    end

    def self.start(argv)
      first = argv.first
      if first && !first.start_with?('-') && !KNOWN_COMMANDS.include?(first)
        puts(command_help_text)
        return 1
      end

      super
      0
    rescue Error => e
      warn("Error: #{e.message}")
      1
    end

    def self.command_help_text
      <<~TEXT
        Commands:
          init
          new_engine ENGINE_NAME
          update_engine_readme ENGINE_NAME
          new_engine_migration ENGINE_NAME MIGRATION_NAME [ARGS...]
          delete_engine_migration ENGINE_NAME PATTERN
          new_engine_model ENGINE_NAME MODEL_NAME [ATTRS...]
          install_engine_migrations ENGINE_NAME
          uninstall_engine_migrations ENGINE_NAME
          remove_engine ENGINE_NAME
      TEXT
    end

    private

    def run_action(klass, argv)
      klass.new(
        argv,
        stdin: $stdin,
        stdout: $stdout,
        stderr: $stderr,
        root: options[:root] || Pathname.pwd
      ).call
    end
  end
end
