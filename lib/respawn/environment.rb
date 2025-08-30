# frozen_string_literal: true

module Respawn
  ENVIRONMENTS = %w[
    development
    production
    test
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

    def self.default
      new(
        ENV.fetch("RUBY_ENV") do
          ENV.fetch("RAILS_ENV", "production")
        end,
      )
    end
  end
end
