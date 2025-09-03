# frozen_string_literal: true

module Respawn
  class NotifierDetector
    # Postpone the actual setup until the first use of the method, to make
    # sure that all the dependencies are loaded and all constants are already
    # available. Memoize the result of first run, to avoid processing all the
    # logic in subsequent invocations.

    def self.call(env: Environment.default)
      if env.test?
        new.call
      else
        @_call ||= new.call
      end
    end

    def call
      detect_notifier
    end

    private

    attr_accessor :notifier

    def detect_notifier
      if defined?(::TestNotifier)
        TestNotifier.method(:call)
      elsif defined?(::Sentry)
        Sentry.method(:capture_exception)
      elsif defined?(::Airbrake)
        :airbrake
      elsif defined?(::Bugsnag)
        :bugsnag
      elsif defined?(::Rollbar)
        :rollbar
      else
        proc do
          raise(
            Error,
            "Notifier called, but no notifier detected!",
          )
        end
      end
    end
  end
end
