# frozen_string_literal: true

module RailsEngineToolkit
  class RoutesRewriter
    def initialize(path)
      @path = Pathname(path)
    end

    def add_mount(engine_class:, mount_path:)
      raise ValidationError, "Routes file not found: #{@path}" unless @path.file?

      content = @path.read
      inspector = RouteInspector.new(content)
      return false if inspector.includes_mount?(engine_class, mount_path)

      mount_line = %(  mount #{engine_class}::Engine, at: "#{mount_path}"\n)

      updated = content.sub(/^(\s*Rails\.application\.routes\.draw do\s*\n)/) do |match|
        "#{match}#{mount_line}"
      end
      raise CommandError, "Could not find Rails.application.routes.draw block in #{@path}" if updated == content

      @path.write(updated)
      true
    end

    def remove_mount(engine_class:, mount_path:)
      raise ValidationError, "Routes file not found: #{@path}" unless @path.file?

      original = @path.read
      lines = original.lines.reject do |line|
        mount_line?(line, engine_class: engine_class, mount_path: mount_path)
      end
      updated = lines.join
      changed = updated != original
      @path.write(updated) if changed
      changed
    end

    private

    def mount_line?(line, engine_class:, mount_path:)
      regexes = [
        mount_comma_regex(engine_class, mount_path),
        mount_parenthesized_regex(engine_class, mount_path),
        mount_hash_rocket_regex(engine_class, mount_path)
      ]
      regexes.any? { |regex| line.match?(regex) }
    end

    def mount_comma_regex(engine_class, mount_path)
      /^\s*mount\s+#{Regexp.escape(engine_class)}::Engine,\s+at:\s+["']#{Regexp.escape(mount_path)}["']\s*$/
    end

    def mount_parenthesized_regex(engine_class, mount_path)
      /^\s*mount\(\s*#{Regexp.escape(engine_class)}::Engine\s*,\s*at:\s+["']#{Regexp.escape(mount_path)}["']\s*\)\s*$/
    end

    def mount_hash_rocket_regex(engine_class, mount_path)
      /^\s*mount\s+#{Regexp.escape(engine_class)}::Engine\s*=>\s*["']#{Regexp.escape(mount_path)}["']\s*$/
    end
  end
end
