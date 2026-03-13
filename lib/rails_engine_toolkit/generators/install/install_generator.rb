# frozen_string_literal: true

require 'rails/generators'

module RailsEngineToolkit
  module Generators
    class InstallGenerator < Rails::Generators::Base
      namespace 'engine_toolkit:install'

      def create_config_file
        require 'rails_engine_toolkit'

        root_path = Pathname(destination_root)
        slug_default = RailsEngineToolkit::Utils.repo_slug_from_path(root_path)
        name_default = RailsEngineToolkit::Utils.humanize_slug(slug_default)

        say_status :info, 'Creating engine toolkit configuration', :blue

        project_slug = ask_with_default('Project slug', slug_default)
        project_name = ask_with_default('Project name', name_default)
        project_url = ask_with_default('Project URL', RailsEngineToolkit::Utils.git_remote_url.to_s)
        author_name = ask_with_default('Author name', RailsEngineToolkit::Utils.git_config('user.name').to_s)
        author_email = ask_with_default('Author email', RailsEngineToolkit::Utils.git_config('user.email').to_s)
        database = ask_with_default('Default database adapter', 'postgresql')

        api_only = yes?('Use API-only engines by default? [Y/n] ', :green)
        skip_asset_pipeline = yes?('Skip asset pipeline by default? [Y/n] ', :green)
        mount_routes = yes?('Mount engine routes automatically? [Y/n] ', :green)
        create_ddd_structure = yes?('Create DDD folders by default? [Y/n] ', :green)

        config_content = RailsEngineToolkit::Templates.render('engine_toolkit_yml', {
                                                                project_slug: project_slug,
                                                                project_name: project_name,
                                                                project_url: project_url,
                                                                author_name: author_name,
                                                                author_email: author_email,
                                                                database: database,
                                                                api_only: api_only,
                                                                skip_asset_pipeline: skip_asset_pipeline,
                                                                mount_routes: mount_routes,
                                                                create_ddd_structure: create_ddd_structure
                                                              })

        create_file 'config/engine_toolkit.yml', config_content

        say ''
        say 'Default configuration created:', :green
        say "  project.slug: #{project_slug}"
        say "  project.name: #{project_name}"
        say "  defaults.database: #{database}"
        say "  defaults.api_only: #{api_only}"
        say "  defaults.mount_routes: #{mount_routes}"
        say "  defaults.create_ddd_structure: #{create_ddd_structure}"
        say ''
        say 'Edit this file to customize the toolkit for your project:', :yellow
        say "  #{File.join(destination_root, 'config/engine_toolkit.yml')}", :yellow
      end

      private

      def ask_with_default(label, default)
        value = ask("#{label} [#{default}]")
        value.present? ? value : default
      end
    end
  end
end
