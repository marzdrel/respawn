# frozen_string_literal: true

require "spec_helper"

module Respawn
  RSpec.describe Environment do
    it "fails with invalid env" do
      expect { described_class.new("invalid") }
        .to raise_error(ArgumentError, /Element.*not found/)
    end

    it "works with test" do
      env = described_class.new("test")

      expect(env.env).to eq("test")
      expect(env.test?).to be(true)
    end
  end
end
