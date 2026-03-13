# frozen_string_literal: true

module RailsEngineToolkit
  class RouteInspector
    Mount = Struct.new(:engine_class, :path, :line)

    def initialize(content)
      @content = content
    end

    def mounts
      return [] unless syntax_valid?

      @content.lines.each_with_index.flat_map do |line, index|
        extract_mounts_from_line(line, index + 1)
      end
    end

    def includes_mount?(engine_class, path)
      mounts.any? { |mount| mount.engine_class == engine_class && mount.path == path }
    end

    def syntax_valid?
      !Ripper.sexp(@content).nil?
    end

    private

    def extract_mounts_from_line(line, line_number)
      patterns = [
        /^\s*mount\s+([A-Z][A-Za-z0-9_:]+)::Engine,\s+at:\s+["']([^"']+)["']\s*$/,
        /^\s*mount\(([^,]+)::Engine,\s*at:\s+["']([^"']+)["']\s*\)\s*$/,
        /^\s*mount\s+([A-Z][A-Za-z0-9_:]+)::Engine\s*=>\s*["']([^"']+)["']\s*$/
      ]

      patterns.filter_map do |pattern|
        match = line.match(pattern)
        next unless match

        Mount.new(engine_class: match[1], path: match[2], line: line_number)
      end
    end
  end
end
