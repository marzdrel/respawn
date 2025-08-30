# frozen_string_literal: true

require "spec_helper"

module Respawn
  RSpec.describe Try do
    context "with constant failure" do
      it "retries the call and raises error" do
        service = described_class.new(ArgumentError, EOFError, onfail: :raise)

        expect_result = expect do
          service.call { raise ArgumentError, "test" }
        end

        expect_result.to raise_error ArgumentError
      end
    end

    context "with single failure" do
      it "retries the call and succeeds" do
        service = described_class.new(ArgumentError, EOFError, onfail: :raise)
        done = nil
        expect_result = expect do
          service.call do
            unless done
              done = true
              raise ArgumentError, "test"
            end
          end
        end

        expect_result.not_to raise_error
      end
    end

    context "with muted soft fail" do
      it "waits between tries" do
        service =
          described_class.new(
            ArgumentError,
            EOFError,
            onfail: :nothing,
            env: Environment.new("production"),
          )

        allow(Kernel).to receive_messages(sleep: true)

        service.call { raise ArgumentError, "test" }

        expect(Kernel)
          .to have_received(:sleep)
          .with(0.5)
          .exactly(4)
          .times
      end

      it "does not send notification" do
        stub_const("TestNotifier", proc {})
        allow(TestNotifier).to receive(:call)

        service = described_class.new(ArgumentError, EOFError, onfail: :nothing)

        service.call { raise ArgumentError, "test" }

        expect(TestNotifier)
          .not_to have_received(:call)
      end
    end

    context "with soft fail and non-test" do
      it "waits between tries and sends notification" do
        stub_const("TestNotifier", proc {})
        allow(TestNotifier).to receive(:call)

        service =
          described_class.new(
            ArgumentError,
            onfail: :notify,
            env: Environment.new("production"),
          )

        allow(Kernel).to receive_messages(sleep: true)

        service.call { raise ArgumentError, "test" }

        expect(TestNotifier)
          .to have_received(:call)
          .with(instance_of(ArgumentError))

        expect(Kernel)
          .to have_received(:sleep)
          .with(0.5)
          .exactly(4)
          .times
      end
    end

    context "with unknown parameters" do
      it "raises constraint error" do
        code = proc do
          described_class.new(ArgumentError, EOFError, onfail: :other)
        end

        expect { code.call }
          .to raise_error KeyError
      end
    end

    context "with unknown failure" do
      it "does not retry when no error occurs" do
        service =
          described_class.new(
            ArgumentError,
            EOFError,
            onfail: :notify,
            env: Environment.new("production"),
          )

        allow(Kernel).to receive_messages(sleep: true)

        service.call { nil }

        expect(Kernel).not_to have_received(:sleep)
      end

      it "does not capture_exception when no error occurs" do
        stub_const("TestNotifier", proc {})
        allow(TestNotifier).to receive(:call)
        allow(Kernel).to receive_messages(sleep: true)

        service = described_class.new(ArgumentError, EOFError, onfail: :notify)

        service.call { nil }

        expect(TestNotifier)
          .not_to have_received(:call)
      end
    end

    context "with network_errors" do
      it "retries and raises error" do
        allow(Kernel).to receive_messages(sleep: true)

        code = proc do
          described_class.call(:network_errors, tries: 2, onfail: :raise) do
            raise EOFError
          end
        end

        expect { code.call }
          .to raise_error EOFError
      end
    end

    it "executes custom logic on failure" do
      service =
        described_class.new(
          ArgumentError,
          EOFError,
          onfail: :handler,
        )

      allow(Kernel).to receive_messages(sleep: true)

      code = proc do
        service.call do |on_error|
          on_error.define do |exception|
            "This is failed due to #{exception.class}"
          end

          raise ArgumentError, "test"
        end
      end

      expect(code.call).to eq "This is failed due to ArgumentError"
    end

    it "allows handler only if onfail is a handler" do
      service =
        described_class.new(
          ArgumentError,
          EOFError,
          onfail: :raise,
        )

      allow(Kernel).to receive_messages(sleep: true)

      code = proc do
        service.call do |on_error|
          on_error.define do |exception|
            "This is failed due to #{exception.class}"
          end

          raise ArgumentError, "test"
        end
      end

      expect { code.call }
        .to raise_error(
          Respawn::Try::Error,
          "Cannot define a block unless onfail is :handler",
        )
    end
  end
end
