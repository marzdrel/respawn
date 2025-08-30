# frozen_string_literal: true

module Respawn
  class NotifierDetector
    def self.call(...)
      new(...).call
    end

    def call
      detect_notifier
    end

    private

    def detect_notifier
      if defined?(TestNotifier)
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
        proc {}
      end
    end
  end
end
