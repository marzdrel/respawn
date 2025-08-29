module Respawn
  class Handler
    def initialize(onfail)
      self.onfail = onfail
    end

    def define(&block)
      if onfail == :handler
        self.block = block
      else
        raise Try::Error, "Cannot define a block unless onfail is :handler"
      end
    end

    attr_reader :block

    private

    attr_accessor :onfail
    attr_writer :block
  end
end
