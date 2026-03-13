# frozen_string_literal: true

module RailsEngineToolkit
  module Utils
    module_function

    def snake_case?(value)
      value.is_a?(String) && value.match?(/\A[a-z0-9_]+\z/)
    end

    def classify(snake_name)
      snake_name.split('_').map(&:capitalize).join
    end

    def humanize_slug(slug)
      slug.split('_').map(&:capitalize).join(' ')
    end

    def repo_slug_from_path(pathname)
      File.basename(Pathname(pathname).expand_path.to_s)
    end

    def ask(prompt, default: nil, input: $stdin, output: $stdout)
      shown = default.nil? || default.to_s.empty? ? "#{prompt}: " : "#{prompt} [#{default}]: "
      output.print(shown)
      answer = input.gets&.chomp
      return default if answer.nil? || answer.empty?

      answer
    end

    def ask_yes_no(prompt, default: false, input: $stdin, output: $stdout)
      suffix = default ? ' [Y/n]: ' : ' [y/N]: '
      output.print("#{prompt}#{suffix}")
      answer = input.gets&.chomp.to_s.strip.downcase
      return default if answer.empty?

      %w[y yes].include?(answer)
    end

    def safe_system(*cmd, chdir:)
      success = system(*cmd, chdir: chdir.to_s)
      raise CommandError, "Command failed: #{cmd.join(' ')}" unless success
    end

    def git_config(key)
      value = `git config #{key} 2>/dev/null`.to_s.strip
      value.empty? ? nil : value
    end

    def git_remote_url
      value = `git remote get-url origin 2>/dev/null`.to_s.strip
      value.empty? ? nil : value
    end
  end
end
