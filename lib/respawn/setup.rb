# frozen_string_literal: true

module Respawn
  OPTIONS = {
    notifier: NotifierDetector,
    cause: ExceptionDetector,
    predicate: [],
    tries: 3,
    wait: 0.5,
    env: -> { Environment.new(ENV.fetch("RACK_ENV", "development")) },
  }

  Setup =
    Data.define(*OPTIONS.keys) do
      def initialize(**options)
        with_defaults =
          OPTIONS.map.to_h do |key, value|
            [
              key,
              options.fetch(key) do
                if value.respond_to?(:call)
                  value.call
                else
                  value
                end
              end
            ]
          end

        super(with_defaults)
      end
    end
end
