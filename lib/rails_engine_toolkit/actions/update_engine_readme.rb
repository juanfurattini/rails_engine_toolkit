# frozen_string_literal: true

module RailsEngineToolkit
  module Actions
    class UpdateEngineReadme
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

        engine_path = @project.engine_path(@engine_name)
        readme = engine_path.join('README.md')
        migrations_dir = engine_path.join('db/migrate')

        raise ValidationError, "README not found: #{readme}" unless readme.file?

        owned_tables_block = tables_from(migrations_dir).then do |tables|
          tables.empty? ? '- None defined yet.' : tables.map { |table| "- #{table}" }.join("\n")
        end

        content = readme.read
        unless content.match?(/^## Owned tables$/)
          raise ValidationError,
                "Could not find '## Owned tables' section in #{readme}"
        end

        updated = content.sub(/^## Owned tables$.*?(?=^## |\z)/m, "## Owned tables\n#{owned_tables_block}\n\n")
        readme.write(updated)

        @stdout.puts("Updated README: #{readme}")
      end

      private

      def validate_args!
        raise ValidationError, 'Engine name is required.' if @engine_name.to_s.empty?
        raise ValidationError, 'Engine name must be snake_case.' unless Utils.snake_case?(@engine_name)

        engine_path = @project.engine_path(@engine_name)
        raise ValidationError, "Engine does not exist: #{engine_path}" unless engine_path.directory?
      end

      def tables_from(migrations_dir)
        return [] unless migrations_dir.directory?

        migrations_dir.glob('*.rb').flat_map do |file|
          file.read.scan(/create_table\s+:?"?([a-zA-Z0-9_]+)"?/).flatten
        end.uniq.sort
      end
    end
  end
end
