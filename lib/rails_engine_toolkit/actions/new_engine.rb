# frozen_string_literal: true

module RailsEngineToolkit
  module Actions
    class NewEngine
      def initialize(argv, stdin:, stdout:, root:, stderr: nil)
        @engine_name = argv[0]
        @stdin = stdin
        @stdout = stdout
        @stderr = stderr
        @root = Pathname(root)
        @project = Project.new(@root)
      end

      def call
        @project.validate_root!
        validate_engine_name!

        config = @project.config
        handle_broken_references!
        ensure_engine_does_not_exist!

        description = prompt_description(config.project_name)
        engine_class = Utils.classify(@engine_name)

        generate_engine!(config)
        rewrite_engine_files!(config, description, engine_class)
        create_ddd_structure!(config)
        mount_engine_route(engine_class) if config.mount_routes?
        Utils.safe_system('bundle', 'install', chdir: @root)

        @stdout.puts("Engine created: engines/#{@engine_name}")
      end

      private

      def validate_engine_name!
        raise ValidationError, 'Engine name is required.' if @engine_name.to_s.empty?
        raise ValidationError, 'Engine name must be snake_case.' unless Utils.snake_case?(@engine_name)
      end

      def handle_broken_references!
        broken = @project.broken_engine_references
        return if broken.empty?

        message = "Broken engine references found in Gemfile (#{broken.join(', ')}). Remove them automatically?"
        remove = Utils.ask_yes_no(
          message,
          default: false,
          input: @stdin,
          output: @stdout
        )
        raise ValidationError, 'Please fix the Gemfile before creating a new engine.' unless remove

        @project.remove_broken_engine_references!(broken)
      end

      def ensure_engine_does_not_exist!
        engine_path = @project.engine_path(@engine_name)
        raise ValidationError, "Engine already exists: #{engine_path}" if engine_path.exist?
      end

      def prompt_description(project_name)
        default = "Provides #{@engine_name} domain for #{project_name}"
        Utils.ask('Engine description', default: default, input: @stdin, output: @stdout)
      end

      def generate_engine!(config)
        args = ['bundle', 'exec', 'rails', 'plugin', 'new', "engines/#{@engine_name}", '--mountable', '-d',
                config.default_database]
        args << '--api' if config.api_only?
        args.concat(config.skip_flags)
        Utils.safe_system(*args, chdir: @root)
      end

      def rewrite_engine_files!(config, description, engine_class)
        engine_path = @project.engine_path(@engine_name)
        engine_path.join('Gemfile').write("source \"https://rubygems.org\"\n\ngemspec\n")
        engine_path.join("#{@engine_name}.gemspec").write(
          Templates.render(
            'gemspec',
            engine_name: @engine_name,
            engine_class: engine_class,
            author_name: config.author_name,
            author_email: config.author_email,
            summary: "#{engine_class} domain engine",
            description: description,
            project_url: config.project_url,
            ruby_version: config.ruby_version,
            rails_version: config.rails_version,
            license: config.license
          )
        )
        engine_path.join('MIT-LICENSE').write(
          Templates.render(
            'license',
            year: Time.now.year,
            author_name: config.author_name,
            license: config.license
          )
        )
        engine_path.join('README.md').write(
          Templates.render(
            'engine_readme',
            engine_name: @engine_name,
            engine_class: engine_class,
            description: description
          )
        )
      end

      def create_ddd_structure!(config)
        return unless config.create_ddd_structure?

        engine_path = @project.engine_path(@engine_name)
        config.ddd_folders.each { |folder| FileUtils.mkdir_p(engine_path.join(folder)) }
      end

      def mount_engine_route(engine_class)
        return unless @project.routes_file.file?

        rewriter = RoutesRewriter.new(@project.routes_file)
        rewriter.add_mount(engine_class: engine_class, mount_path: "/#{@engine_name}")
      end
    end
  end
end
