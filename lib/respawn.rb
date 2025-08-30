# frozen_string_literal: true

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load

module Respawn
  class Error < StandardError; end

  def self.try(...)
    Try.call(...)
  end

  DefaultSetup =
    Setup.new(
      notifier: NotifierDetector.call,
      cause: ExceptionDetector.call,
    )
end
