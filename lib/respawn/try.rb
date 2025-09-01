module Respawn
  class Try
    using ArrayTry

    def self.call(*, **, &)
      new(*, **).call(&)
    end

    def initialize(*exceptions, **options)
      exceptions = [:net] if exceptions.empty?

      options.keys.each { OPTIONS.keys.try!(it) }

      self.setup = options.fetch(:setup, Setup.new(**options))
      self.notifier = options.fetch(:notifier, setup.notifier)
      self.predicate = options.fetch(:predicate, setup.predicate)
      self.exceptions = parse_exceptions(exceptions) + [PredicateError]
      self.tries = options.fetch(:tries, setup.tries)
      self.onfail = ONFAIL.try! options.fetch(:onfail, setup.onfail)
      self.wait = options.fetch(:wait, setup.wait)
      self.env = options.fetch(:env, Environment.default)

      self.handler = Handler.new(onfail)
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

    attr_accessor(
      :exceptions,
      :tries,
      :onfail,
      :wait,
      :handler,
      :env,
      :predicate,
      :setup,
      :notifier,
    )

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

    def perform_fail(exception)
      case onfail
      in :notify
        notifier.call(exception)
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
        if exception == :net
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
