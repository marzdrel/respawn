require "spec_helper"

module Respawn
  RSpec.describe NotifierDetector do
    describe ".call" do
      it "infers expected notifier" do
        stub_const("TestNotifier", proc {})
        allow(TestNotifier).to receive(:call)

        described_class.call.call

        expect(TestNotifier).to have_received(:call)
      end

      it "emits warning without notifier" do
        expect { described_class.call.call }
          .to raise_error(Error, /no notifier detected/)
      end

      it "does memoization in production only" do
        stub_const("TestNotifier", proc { :notifier })

        env = Environment.new("production")

        expect(described_class.call(env:).call)
          .to eq(:notifier)

        stub_const("TestNotifier", proc { raise "This should not happen" })

        expect { described_class.call(env:).call }
          .not_to raise_error
      end
    end
  end
end
