# frozen_string_literal: true

module Respawn
  ENVIRONMENTS = [
    "development",
    "production",
    "test",
  ].freeze

  Environment = Data.define(:env) do
    def initialize(env:)
      ENVIRONMENTS.include?(env) or
        raise ArgumentError, "Invalid environment: #{env.inspect}"

      super
    end

    ENVIRONMENTS.each do |name|
      define_method("#{name}?") do
        env == name
      end
    end
  end
end
