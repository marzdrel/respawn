# frozen_string_literal: true

module Respawn
  class NotifierDetector
    # Postpone the actual setup until the first use of the method, to make
    # sure that all the dependencies are loaded and all constants are already
    # available. Memoize the result of first run, to avoid processing all the
    # logic in subsequent invocations.

    def self.call(notifier: nil)
      if notifier
        new(notifier:).call
      else
        @_call ||= new(notifier:).call
      end
    end

    # Only reason for the inject here is for testing. Memoization will run the
    # block once, preventing mocking in test.

    def initialize(notifier:)
      self.notifier = notifier
    end

    def call
      notifier || detect_notifier
    end

    private

    attr_accessor :notifier

    def detect_notifier
      if defined?(::Sentry)
        Sentry.method(:capture_exception)
      elsif defined?(::Airbrake)
        :airbrake
      elsif defined?(::Bugsnag)
        :bugsnag
      elsif defined?(::Rollbar)
        :rollbar
      else
        proc {}
      end
    end
  end
end
