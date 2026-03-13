# frozen_string_literal: true

module RailsEngineToolkit
  module Actions
    class Init
      def initialize(_argv, stdin:, stdout:, root:, stderr: nil)
        @stdin = stdin
        @stdout = stdout
        @stderr = stderr
        @root = Pathname(root)
        @project = Project.new(@root)
      end

      def call
        @project.validate_root!
        answers = prompt_values

        FileUtils.mkdir_p(@project.config_file.dirname)
        @project.config_file.write(
          Templates.render('engine_toolkit_yml', answers)
        )

        @stdout.puts("Created #{@project.config_file}")
        @stdout.puts('Edit this file to customize the toolkit for your project:')
        @stdout.puts("  #{@project.config_file}")
      end

      private

      def prompt_values
        slug_default = Utils.repo_slug_from_path(@root)
        name_default = Utils.humanize_slug(slug_default)

        {
          project_slug: Utils.ask('Project slug', default: slug_default, input: @stdin, output: @stdout),
          project_name: Utils.ask('Project name', default: name_default, input: @stdin, output: @stdout),
          project_url: Utils.ask('Project URL', default: Utils.git_remote_url.to_s, input: @stdin, output: @stdout),
          author_name: Utils.ask('Author name', default: Utils.git_config('user.name').to_s, input: @stdin,
                                                output: @stdout),
          author_email: Utils.ask('Author email', default: Utils.git_config('user.email').to_s, input: @stdin,
                                                  output: @stdout),
          database: Utils.ask('Default database adapter', default: 'postgresql', input: @stdin, output: @stdout),
          api_only: Utils.ask_yes_no('Use API-only engines by default?', default: true, input: @stdin, output: @stdout),
          skip_asset_pipeline: Utils.ask_yes_no('Skip asset pipeline by default?', default: true, input: @stdin,
                                                                                   output: @stdout),
          mount_routes: Utils.ask_yes_no('Mount engine routes automatically?', default: true, input: @stdin,
                                                                               output: @stdout),
          create_ddd_structure: Utils.ask_yes_no('Create DDD folders by default?', default: true, input: @stdin,
                                                                                   output: @stdout)
        }
      end
    end
  end
end
