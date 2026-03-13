# frozen_string_literal: true

module RailsEngineToolkit
  module Actions
    class NewEngineMigration
      def initialize(argv, stdout:, root:, stdin: nil, stderr: nil)
        @engine_name = argv.shift
        @generator_args = argv
        @stdout = stdout
        @stdin = stdin
        @stderr = stderr
        @root = Pathname(root)
        @project = Project.new(@root)
      end

      def call
        @project.validate_root!
        raise ValidationError, 'Engine name is required.' if @engine_name.to_s.empty?
        raise ValidationError, 'Migration name is required.' if @generator_args.empty?

        engine_path = @project.engine_path(@engine_name)
        raise ValidationError, "Engine does not exist: #{engine_path}" unless engine_path.directory?

        Utils.safe_system('bin/rails', 'g', 'migration', *@generator_args, chdir: engine_path)
        UpdateEngineReadme.new([@engine_name], stdin: nil, stdout: @stdout, stderr: nil, root: @root).call
        @stdout.puts("Migration created inside #{engine_path}")
      end
    end
  end
end
