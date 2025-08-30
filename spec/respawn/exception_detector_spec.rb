# frozen_string_literal: true

require "spec_helper"

module Respawn
  RSpec.describe ExceptionDetector do
    describe "#call" do
      it "returns SocketError if exists" do
        stub_const("SocketError", Class.new(StandardError))

        expect(described_class.call)
          .to include(SocketError)
      end

      it "always doesn't include undefined constant" do
        expect(described_class.call)
          .to eq ExceptionDetector::PREDEFINED_EXCEPTIONS
      end
    end
  end
end
