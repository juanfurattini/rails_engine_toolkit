# frozen_string_literal: true

module RailsEngineToolkit
  class FileEditor
    def self.remove_lines_matching(path, regex)
      return false unless path.exist?

      original = path.read
      updated = original.lines.grep_v(regex).join
      changed = original != updated
      path.write(updated) if changed
      changed
    end

    def self.insert_after_first_match(path, match_regex, text)
      content = path.read
      updated = content.sub(match_regex) { |m| "#{m}#{text}" }
      changed = updated != content
      path.write(updated) if changed
      changed
    end

    def self.ensure_line_after_draw_block(path, line)
      return false unless path.exist?

      content = path.read
      return false if content.include?(line.strip)

      updated = content.sub(/Rails\.application\.routes\.draw do\s*\n/, "Rails.application.routes.draw do\n#{line}")
      changed = updated != content
      path.write(updated) if changed
      changed
    end

    def self.copy_file(path_from, path_to)
      FileUtils.mkdir_p(path_to.dirname)
      FileUtils.cp(path_from, path_to)
    end
  end
end
