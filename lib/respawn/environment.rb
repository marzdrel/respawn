# frozen_string_literal: true

module Respawn
  ENVIRONMENTS = [
    "development",
    "production",
    "test",
  ].freeze

  Environment = Data.define(:env) do
    using ArrayTry

    def initialize(env:)
      ENVIRONMENTS.try!(env)

      super
    end

    ENVIRONMENTS.each do |name|
      define_method("#{name}?") do
        env == name
      end
    end
  end
end
