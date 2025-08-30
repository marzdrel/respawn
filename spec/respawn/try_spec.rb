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
          .to raise_error ArgumentError, /Element "other" not found in array/
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
        service.call do |handler|
          handler.define do |exception|
            "This failed due to #{exception.class}"
          end

          raise ArgumentError, "test"
        end
      end

      expect(code.call).to eq "This failed due to ArgumentError"
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
        service.call do |handler|
          handler.define do |exception|
            "This failed due to #{exception.class}"
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

    it "passses the output through predicate and failes" do
      response = Data.define(:status, :body).new(500, "error")

      predicate =
        proc do |response|
          response.status >= 500
        end

      service =
        described_class.new(
          ArgumentError,
          onfail: :handler,
          predicate: predicate,
        )

      result =
        service.call do |handler|
          handler.define do |exception|
            "This failed due to #{exception.class}"
          end

          response
        end

      expect(result).to eq "This failed due to Respawn::PredicateError"
    end

    it "raises default predicate error" do
      service =
        described_class.new(
          ArgumentError,
          onfail: :raise,
          predicate: proc { true },
        )

      expect { service.call { 1 + 1 } }
        .to raise_error(Respawn::PredicateError, /Predicate #0 matched/)
    end

    it "passses the output through predicate and succeedes" do
      http_response = Data.define(:status, :body)

      responses = [
        http_response.new(500, "error"),
        http_response.new(200, "error"),
        http_response.new(500, "error"),
        http_response.new(201, "created"),
      ]

      predicates = [
        proc { it.status >= 500 },
        proc { it.body == "error" },
      ]

      service =
        described_class.new(
          ArgumentError,
          onfail: :handler,
          predicate: predicates,
        )

      result =
        service.call do |handler|
          handler.define do |exception|
            "This failed due to #{exception.class}"
          end

          responses[handler.retry_number]
        end

      expect(result).to eq http_response.new(201, "created")
    end
  end
end
