# frozen_string_literal: true

module RailsEngineToolkit
  module Actions
    class UninstallEngineMigrations
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

        root_matches = matching_root_migrations
        if root_matches.empty?
          @stdout.puts("No installed root migrations found for engine '#{@engine_name}'.")
          return
        end

        print_matches(root_matches)
        confirm_uninstall!
        root_matches.each(&:delete)

        @stdout.puts("Removed #{root_matches.size} root migration file(s) for engine '#{@engine_name}'.")
      end

      private

      def validate_engine!
        raise ValidationError, 'Engine name is required.' if @engine_name.to_s.empty?
        raise ValidationError, 'Engine name must be snake_case.' unless Utils.snake_case?(@engine_name)

        engine_path = @project.engine_path(@engine_name)
        migrations_dir = engine_path.join('db/migrate')
        raise ValidationError, "Engine does not exist: #{engine_path}" unless engine_path.directory?

        return if migrations_dir.directory?

        raise ValidationError,
              "Engine migrations directory not found: #{migrations_dir}"
      end

      def matching_root_migrations
        return [] unless @project.root_migrations_dir.directory?

        engine_basenames = @project.engine_path(@engine_name).join('db/migrate').glob('*.rb').map do |file|
          file.basename.to_s.sub(/^\d+_/, '')
        end.sort

        @project.root_migrations_dir.glob('*.rb').select do |file|
          engine_basenames.include?(file.basename.to_s.sub(/^\d+_/, ''))
        end.sort
      end

      def print_matches(root_matches)
        @stdout.puts("The following root migrations match engine '#{@engine_name}':")
        root_matches.each { |file| @stdout.puts("  #{file.relative_path_from(@root)}") }
        @stdout.puts('')
        @stdout.puts('This only removes copied migration files from db/migrate.')
        @stdout.puts('It does NOT rollback the database automatically.')
        @stdout.puts('Run your rollback or down migrations manually if needed.')
      end

      def confirm_uninstall!
        confirmed = Utils.ask(
          "Type '#{@engine_name}' to confirm uninstall",
          input: @stdin,
          output: @stdout
        )
        raise ValidationError, 'Operation aborted.' unless confirmed == @engine_name
      end
    end
  end
end
