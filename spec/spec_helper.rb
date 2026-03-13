# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'
require 'stringio'
require 'yaml'

require 'rails_engine_toolkit'

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end

module SpecHelpers
  def in_tmpdir
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) { yield Pathname(dir) }
    end
  end

  def write(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end
