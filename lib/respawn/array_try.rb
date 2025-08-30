# frozen_string_literal: true

module Respawn
  module ArrayTry
    refine Array do
      def try!(element)
        include?(element) or
          raise(
            ArgumentError,
            %(Element "#{element}" not found in array #{self}),
          )

        element
      end
    end
  end
end
