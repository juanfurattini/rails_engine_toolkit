# frozen_string_literal: true

module RailsEngineToolkit
  module Templates
    module_function

    def render(name, locals = {})
      template = Pathname(__dir__).join("templates/#{name}.erb").read
      ERB.new(template, trim_mode: '-').result_with_hash(locals)
    end
  end
end
