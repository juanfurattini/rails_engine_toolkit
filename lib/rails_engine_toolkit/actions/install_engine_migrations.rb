# frozen_string_literal: true

module RailsEngineToolkit
  module Actions
    class InstallEngineMigrations
      def initialize(argv, stdout:, root:, stdin: nil, stderr: nil)
        @engine_name = argv[0]
        @stdout = stdout
        @stdin = stdin
        @stderr = stderr
        @root = Pathname(root)
        @project = Project.new(@root)
      end

      def call
        @project.validate_root!
        validate_args!

        migrations_dir = engine_migrations_dir
        FileUtils.mkdir_p(@project.root_migrations_dir)

        copied = migrations_to_copy(migrations_dir).map do |source_file|
          copy_migration(source_file)
        end

        report_result(copied)
      end

      private

      def validate_args!
        raise ValidationError, 'Engine name is required.' if @engine_name.to_s.empty?
        raise ValidationError, 'Engine name must be snake_case.' unless Utils.snake_case?(@engine_name)

        engine_path = @project.engine_path(@engine_name)
        raise ValidationError, "Engine does not exist: #{engine_path}" unless engine_path.directory?
      end

      def engine_migrations_dir
        migrations_dir = @project.engine_path(@engine_name).join('db/migrate')
        unless migrations_dir.directory?
          raise ValidationError,
                "Engine migrations directory not found: #{migrations_dir}"
        end

        migrations_dir
      end

      def migrations_to_copy(migrations_dir)
        existing = @project.root_migrations_dir.glob('*.rb').map do |file|
          file.basename.to_s.sub(/^\d+_/, '')
        end

        migrations_dir.glob('*.rb').sort.reject do |file|
          existing.include?(file.basename.to_s.sub(/^\d+_/, ''))
        end
      end

      def copy_migration(source_file)
        basename_without_version = source_file.basename.to_s.sub(/^\d+_/, '')
        destination = @project.root_migrations_dir.join("#{next_timestamp}_#{basename_without_version}")
        FileEditor.copy_file(source_file, destination)
        destination
      end

      def report_result(copied)
        if copied.empty?
          @stdout.puts("No new migrations to install for engine '#{@engine_name}'.")
          return
        end

        @stdout.puts("Installed #{copied.size} migration(s) for engine '#{@engine_name}':")
        copied.each { |file| @stdout.puts("  #{file.relative_path_from(@root)}") }
      end

      def next_timestamp
        @counter ||= 0
        @counter += 1
        (Time.now.utc + @counter).strftime('%Y%m%d%H%M%S')
      end
    end
  end
end
