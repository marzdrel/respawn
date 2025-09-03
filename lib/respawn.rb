# frozen_string_literal: true

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load

module Respawn
  class Error < StandardError; end
  class PredicateError < StandardError; end

  def self.try(...)
    Try.call(...)
  end
end
