# frozen_string_literal: true

module Respawn
  RSpec.describe Respawn do
    it "has a version number" do
      expect(VERSION).not_to be nil
    end

    describe "#try" do
      it "executes the logic" do
        expect(Respawn.try { 1 + 1 }).to eq(2)
      end

      it "calls the implementation" do
        allow(Try).to receive_messages(call: :result)

        expect(Respawn.try).to eq(:result)
      end
    end
  end
end
