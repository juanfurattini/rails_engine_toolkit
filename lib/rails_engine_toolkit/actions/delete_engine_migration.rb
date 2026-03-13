# frozen_string_literal: true

module RailsEngineToolkit
  module Actions
    class DeleteEngineMigration
      def initialize(argv, stdin:, stdout:, root:, stderr: nil)
        @engine_name = argv[0]
        @pattern = argv[1]
        @stdin = stdin
        @stdout = stdout
        @stderr = stderr
        @root = Pathname(root)
        @project = Project.new(@root)
      end

      def call
        @project.validate_root!
        validate_args!

        migrations_dir = @project.engine_path(@engine_name).join('db/migrate')
        raise ValidationError, "Migrations path does not exist: #{migrations_dir}" unless migrations_dir.directory?

        matches = migrations_dir.glob("*#{@pattern}*.rb").sort
        raise ValidationError, "No migrations found matching '#{@pattern}'." if matches.empty?

        confirmed = Utils.ask(
          "Type '#{@engine_name}' to confirm deletion",
          input: @stdin,
          output: @stdout
        )
        raise ValidationError, 'Operation aborted.' unless confirmed == @engine_name

        matches.each(&:delete)
        UpdateEngineReadme.new([@engine_name], stdin: @stdin, stdout: @stdout, stderr: nil, root: @root).call
        @stdout.puts("Deleted #{matches.size} migration(s)")
      end

      private

      def validate_args!
        raise ValidationError, 'Engine name is required.' if @engine_name.to_s.empty?
        raise ValidationError, 'Migration match pattern is required.' if @pattern.to_s.empty?
      end
    end
  end
end
