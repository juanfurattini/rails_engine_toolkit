# frozen_string_literal: true

module RailsEngineToolkit
  class Error < StandardError; end
  class ValidationError < Error; end
  class CommandError < Error; end
end
