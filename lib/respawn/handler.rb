module Respawn
  class Handler
    def initialize(onfail)
      self.onfail = onfail
      self.retry_number = 0
      # self.predicates = []
    end

    # def predicate(&block)
    #   self.predicates << block
    # end

    def define(&block)
      return if self.block

      if onfail != :handler
        raise Error, "Cannot define a block unless onfail is :handler"
      end

      self.block = block
    end

    attr_accessor :onfail, :retry_number

    attr_reader :block

    private

    attr_accessor :onfail, :predicates
    attr_writer :block
  end
end
