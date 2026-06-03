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
  end
end
