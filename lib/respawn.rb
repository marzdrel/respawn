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

  # Postpone the actuall setup until the first use of the method, to make
  # sure that all the dependencies are loaded and all constants are already
  # available.

  def self.default_setup
    @_default_setup ||=
      Setup.new(
        notifier: NotifierDetector.call,
        cause: ExceptionDetector.call,
        predicate: [],
      )
  end
end
