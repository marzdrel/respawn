# frozen_string_literal: true

require "zeitwerk"

module Respawn
  class Error < StandardError; end
end

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load
