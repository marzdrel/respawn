# frozen_string_literal: true

require "spec_helper"

module Respawn
  RSpec.describe Environment do
    it "works with test" do
      env = described_class.new("test")

      expect(env.env).to eq("test")
      expect(env.test?).to be(true)
      expect(env.other?).to be(false)
    end

    it "treats any non-test env as other" do
      env = described_class.new("staging")

      expect(env.env).to eq("staging")
      expect(env.test?).to be(false)
      expect(env.other?).to be(true)
    end

    describe ".default" do
      def with_env(values)
        keys = %w[RUBY_ENV RAILS_ENV RACK_ENV]
        saved = keys.to_h { |key| [key, ENV[key]] }

        keys.each { |key| ENV.delete(key) }
        values.each { |key, value| ENV[key] = value }

        yield
      ensure
        keys.each do |key|
          saved[key].nil? ? ENV.delete(key) : ENV[key] = saved[key]
        end
      end

      it "prefers RUBY_ENV over the others" do
        with_env(
          "RUBY_ENV" => "test",
          "RAILS_ENV" => "production",
          "RACK_ENV" => "staging",
        ) do
          expect(described_class.default.env).to eq("test")
        end
      end

      it "falls back to RAILS_ENV when RUBY_ENV is missing" do
        with_env("RAILS_ENV" => "staging", "RACK_ENV" => "production") do
          expect(described_class.default.env).to eq("staging")
        end
      end

      it "falls back to RACK_ENV when only it is set" do
        with_env("RACK_ENV" => "staging") do
          expect(described_class.default.env).to eq("staging")
        end
      end

      it "defaults to production when nothing is set" do
        with_env({}) do
          expect(described_class.default.env).to eq("production")
        end
      end
    end
  end
end
