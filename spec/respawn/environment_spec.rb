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
      it "prefers RUBY_ENV over the others" do
        stub_env(
          "RUBY_ENV" => "test",
          "RAILS_ENV" => "production",
          "RACK_ENV" => "staging",
        )

        expect(described_class.default.env).to eq("test")
      end

      it "falls back to RAILS_ENV when RUBY_ENV is missing" do
        stub_env("RAILS_ENV" => "staging", "RACK_ENV" => "production")

        expect(described_class.default.env).to eq("staging")
      end

      it "falls back to RACK_ENV when only it is set" do
        stub_env("RACK_ENV" => "staging")

        expect(described_class.default.env).to eq("staging")
      end

      it "defaults to production when nothing is set" do
        stub_env({})

        expect(described_class.default.env).to eq("production")
      end
    end
  end
end
