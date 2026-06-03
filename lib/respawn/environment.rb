# frozen_string_literal: true

module Respawn
  Environment = Data.define(:env) do
    def test?
      env == "test"
    end

    def other?
      !test?
    end

    def self.default
      new(
        ENV.fetch("RUBY_ENV") do
          ENV.fetch("RAILS_ENV") do
            ENV.fetch("RACK_ENV", "production")
          end
        end,
      )
    end
  end
end
