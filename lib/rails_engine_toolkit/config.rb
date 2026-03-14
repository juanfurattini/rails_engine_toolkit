# frozen_string_literal: true

module RailsEngineToolkit
  class Config
    DEFAULT_PATH = 'config/engine_toolkit.yml'

    REQUIRED_TOP_LEVEL_KEYS = %w[project author defaults metadata].freeze
    VALID_DATABASES = %w[postgresql mysql2 sqlite3].freeze
    DEFAULT_DDD_FOLDERS = [
      'app/use_cases',
      'app/services',
      'app/policies',
      'app/serializers',
      'app/repositories',
      'app/contracts'
    ].freeze
    SKIP_FLAG_MAPPING = {
      'skip_asset_pipeline' => '--skip-asset-pipeline',
      'skip_action_mailbox' => '--skip-action-mailbox',
      'skip_action_text' => '--skip-action-text',
      'skip_active_storage' => '--skip-active-storage',
      'skip_hotwire' => '--skip-hotwire',
      'skip_jbuilder' => '--skip-jbuilder',
      'skip_system_test' => '--skip-system-test',
      "skip_rubocop" => "--skip-rubocop"
    }.freeze

    attr_reader :data

    def self.load(project_root, path: DEFAULT_PATH)
      full_path = Pathname(project_root).join(path)
      raise ValidationError, "Configuration file not found: #{full_path}" unless full_path.exist?

      new(YAML.safe_load(full_path.read, aliases: true) || {}, path: full_path).tap(&:validate!)
    end

    def initialize(data, path:)
      @data = data
      @path = path
    end

    def validate!
      REQUIRED_TOP_LEVEL_KEYS.each do |key|
        raise ValidationError, "Missing config section: #{key} in #{@path}" unless data.key?(key)
      end

      validate_string('project', 'name')
      validate_string('project', 'slug')
      validate_string('author', 'name')
      validate_string('author', 'email')

      raise ValidationError, 'project.slug must be snake_case' unless Utils.snake_case?(project_slug)
      return true if VALID_DATABASES.include?(default_database)

      raise ValidationError, "defaults.database must be one of: #{VALID_DATABASES.join(', ')}"
    end

    def project_name = fetch('project', 'name')
    def project_slug = fetch('project', 'slug')
    def project_url = fetch('project', 'url', default: '')
    def author_name = fetch('author', 'name')
    def author_email = fetch('author', 'email')
    def license = fetch('metadata', 'license', default: 'MIT')
    def ruby_version = fetch('metadata', 'ruby_version', default: '>= 3.2')
    def rails_version = fetch('metadata', 'rails_version', default: '>= 8.1.2')
    def default_database = fetch('defaults', 'database', default: 'postgresql')
    def api_only? = !!fetch('defaults', 'api_only', default: true)
    def mount_routes? = !!fetch('defaults', 'mount_routes', default: true)
    def create_ddd_structure? = !!fetch('defaults', 'create_ddd_structure', default: true)

    def skip_flags
      defaults = data.fetch('defaults', {})
      SKIP_FLAG_MAPPING.filter_map do |key, flag|
        flag if defaults.fetch(key, true)
      end
    end

    def ddd_folders
      fetch('ddd', 'folders', default: DEFAULT_DDD_FOLDERS)
    end

    private

    def validate_string(*keys)
      value = fetch(*keys)
      raise ValidationError, "Missing config value: #{keys.join('.')}" if value.to_s.strip.empty?
    end

    def fetch(*keys, default: nil)
      cursor = data
      keys.each do |key|
        return default unless cursor.is_a?(Hash) && cursor.key?(key)

        cursor = cursor[key]
      end
      cursor.nil? ? default : cursor
    end
  end
end
