# frozen_string_literal: true

module Respawn
  RSpec.describe Setup do
    it "executes the logic" do
      cfg =
        Setup.new(
          notifier: proc(&:message),
          cause: [ArgumentError],
          predicate: [],
        )

      msg = cfg.notifier.call(ArgumentError.new("test"))

      expect(msg).to eq("test")
    end

    it "does not load proc from default if argument is provided" do
      allow(NotifierDetector).to receive(:call)
      allow(ExceptionDetector).to receive(:call)

      described_class.new(notifier: proc(&:message))

      expect(NotifierDetector).not_to have_received(:call)
      expect(ExceptionDetector).to have_received(:call)
    end
  end
end
