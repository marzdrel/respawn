module Respawn
  class Handler
    def initialize(onfail)
      self.onfail = onfail
      self.retry_number = 0
    end

    def define(&block)
      if onfail == :handler
        self.block = block
      else
        raise Try::Error, "Cannot define a block unless onfail is :handler"
      end
    end

    attr_accessor :onfail, :retry_number

    attr_reader :block

    private

    attr_accessor :onfail
    attr_writer :block
  end
end
