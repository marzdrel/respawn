# frozen_string_literal: true

module Respawn
  OPTIONS = {
    notifier: proc { NotifierDetector.call },
    cause: proc { ExceptionDetector.call },
    predicate: [],
  }

  Setup =
    Data.define(*OPTIONS.keys) do
      def initialize(**options)
        with_defaults =
          OPTIONS.map.to_h do |key, value|
            [
              key,
              options.fetch(key) do
                if value.is_a?(Proc)
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
