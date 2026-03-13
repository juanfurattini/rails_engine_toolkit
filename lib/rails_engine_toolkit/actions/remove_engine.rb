# frozen_string_literal: true

module RailsEngineToolkit
  module Actions
    class RemoveEngine
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
        validate_engine!

        warn_if_root_migrations_exist!
        confirm_deletion!

        remove_mounts
        remove_gemfile_entry
        FileUtils.rm_rf(@project.engine_path(@engine_name))
        Utils.safe_system('bundle', 'install', chdir: @root)
        @stdout.puts("Removed engine: #{@engine_name}")
      end

      private

      def validate_engine!
        raise ValidationError, 'Engine name is required.' if @engine_name.to_s.empty?
        raise ValidationError, 'Engine name must be snake_case.' unless Utils.snake_case?(@engine_name)

        engine_path = @project.engine_path(@engine_name)
        raise ValidationError, "Engine does not exist: #{engine_path}" unless engine_path.directory?
      end

      def warn_if_root_migrations_exist!
        installed = @project.matching_root_migrations_for_engine(@engine_name)
        return if installed.empty?

        proceed = Utils.ask_yes_no(
          'Root migrations may belong to this engine. Continue anyway?',
          default: false,
          input: @stdin,
          output: @stdout
        )
        raise ValidationError, 'Operation aborted.' unless proceed
      end

      def confirm_deletion!
        confirmed = Utils.ask(
          "Type '#{@engine_name}' to confirm deletion",
          input: @stdin,
          output: @stdout
        )
        raise ValidationError, 'Operation aborted.' unless confirmed == @engine_name
      end

      def remove_mounts
        return unless @project.routes_file.file?

        RoutesRewriter.new(@project.routes_file).remove_mount(
          engine_class: Utils.classify(@engine_name),
          mount_path: "/#{@engine_name}"
        )
      end

      def remove_gemfile_entry
        FileEditor.remove_lines_matching(
          @project.gemfile,
          %r{path:\s*["']engines/#{Regexp.escape(@engine_name)}["']}
        )
      end
    end
  end
end
