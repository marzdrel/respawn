module Respawn
  Environment = Data.define(:env) do
    def test? = env == "test"
  end

  class Try
    class Error < StandardError; end

    ONFAIL = [
      :notify,
      :nothing,
      :raise,
      :handler,
    ].freeze

    def self.call(*, **, &)
      new(*, **).call(&)
    end

    def initialize(*exceptions, predicate: [], tries: 5, onfail: :notify, wait: 0.5, env: nil)
      self.predicate = predicate
      self.exceptions = parse_exceptions(exceptions) + [PredicateError]
      self.tries = tries
      self.onfail = ONFAIL.zip(ONFAIL).to_h.fetch(onfail)
      self.wait = wait
      self.handler = Handler.new(onfail)
      self.env = env || Environment.new(default_environment)
    end

    def call
      yield(handler)
        .tap(&method(:check_predicates))
    rescue *exceptions => e
      self.tries = tries - 1
      handler.retry_number += 1

      if tries.positive?
        Kernel.sleep(wait) unless env.test?
        retry
      end

      perform_fail(e)
    end

    private

    attr_accessor :exceptions, :tries, :onfail, :wait, :handler, :env, :predicate

    def check_predicates(result)
      Array(predicate).each.with_index do |condition, index|
        if condition.call(result)
          raise(
            PredicateError,
            "Predicate ##{index} matched (#{condition.inspect})",
          )
        end
      end
    end

    def default_environment
      ENV.fetch("RUBY_ENV") do
        ENV.fetch("RAILS_ENV") do
          "production"
        end
      end
    end

    def perform_fail(exception)
      case onfail
      in :notify
        Respawn.default_setup.notifier.call(exception)
      in :nothing
        nil
      in :raise
        raise
      in :handler
        handler.block.call(exception)
      end
    end

    def parse_exceptions(list)
      list.flat_map do |exception|
        if exception == :network_errors
          Respawn.default_setup.cause

        # This comparision will raise an error if the exception is not
        # a class, which is what we want.

        elsif exception <= Exception
          exception
        end
      end
    end
  end
end
