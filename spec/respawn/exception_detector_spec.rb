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

      it "does memoization in production only" do
        stub_const("TestException", Class.new(StandardError))

        env = Environment.new("production")

        exceptions = described_class.call(env:)
        expect(exceptions.size).to eq 5

        hide_const("TestException")

        exceptions = described_class.call(env:)
        expect(exceptions.size).to eq 5
      end

      it "does no memoization in non-production" do
        stub_const("TestException", Class.new(StandardError))

        env = Environment.new("test")

        exceptions = described_class.call(env:)
        expect(exceptions.size).to eq 5

        hide_const("TestException")

        exceptions = described_class.call(env:)
        expect(exceptions.size).to eq 4
      end
    end
  end
end
