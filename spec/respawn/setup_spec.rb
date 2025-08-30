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
  end
end
