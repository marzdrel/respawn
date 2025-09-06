# frozen_string_literal: true

module Respawn
  ONFAIL = [
    :notify,
    :nothing,
    :raise,
    :handler,
  ].freeze

  OPTIONS = {
    notifier: NotifierDetector,
    ex: ExceptionDetector,
    onfail: :raise,
    predicate: [],
    tries: 5,
    wait: 0.5,
    env: -> { Environment.default },
    setup: nil,
  }.freeze

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
