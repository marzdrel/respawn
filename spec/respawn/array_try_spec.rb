# frozen_string_literal: true

require "spec_helper"

module Respawn
  RSpec.describe ArrayTry do
    using described_class

    describe "#try!" do
      it "returns element" do
        expect([1, 2, 3].try!(2)).to eq(2)
      end

      it "raises with missing element" do
        expect { [1, 2, 3].try!(4) }
          .to raise_error(ArgumentError, /Element "4" not found in array/)
      end
    end
  end
end
