# frozen_string_literal: true

module RailsEngineToolkit
  class Project
    attr_reader :root

    def initialize(root = Pathname.pwd)
      @root = Pathname(root).expand_path
    end

    def validate_root!
      raise ValidationError, 'You must run this command from the Rails project root.' unless gemfile.file?

      true
    end

    def config
      @config ||= Config.load(root)
    end

    def gemfile = root.join('Gemfile')
    def routes_file = root.join('config/routes.rb')
    def root_migrations_dir = root.join('db/migrate')
    def config_file = root.join(Config::DEFAULT_PATH)

    def engine_path(engine_name)
      root.join("engines/#{engine_name}")
    end

    def engine_exists?(engine_name)
      engine_path(engine_name).directory?
    end

    def broken_engine_references
      return [] unless gemfile.file?

      gemfile.read.lines.filter_map do |line|
        match = line.match(%r{path:\s*["']engines/([^"']+)["']})
        next unless match

        engine_name = match[1]
        engine_name unless engine_exists?(engine_name)
      end.uniq
    end

    def remove_broken_engine_references!(engine_names)
      return if engine_names.empty?

      content = gemfile.read
      engine_names.each do |name|
        content = content.lines.grep_v(%r{path:\s*["']engines/#{Regexp.escape(name)}["']}).join
      end
      gemfile.write(content)
    end

    def route_inspector
      return nil unless routes_file.file?

      RouteInspector.new(routes_file.read)
    end

    def matching_root_migrations_for_engine(engine_name)
      return [] unless root_migrations_dir.directory?

      engine_class = Utils.classify(engine_name)
      root_migrations_dir.glob('*.rb').select do |file|
        file.read.include?(engine_class) || file.read.include?("#{engine_name}_")
      end
    end
  end
end
