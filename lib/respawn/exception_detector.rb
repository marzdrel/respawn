# frozen_string_literal: true

module Respawn
  class ExceptionDetector
    EXCEPTIONS = [
      "EOFError",
      "Errno::ECONNABORTED",
      "Errno::ECONNRESET",
      "Errno::EHOSTUNREACH",
      "SocketError",
      "Faraday::ConnectionFailed",
      "Faraday::TimeoutError",
      "Faraday::ClientError",
      "Faraday::ServerError",
      "Net::OpenTimeout",
      "Net::ReadTimeout",
      "OpenSSL::SSL::SSLError",
      "OpenURI::HTTPError",
      "TestException",
    ].freeze

    def self.call(env: Environment.default)
      if env.test?
        new.call
      else
        @_call ||= new.call
      end
    end

    def call
      EXCEPTIONS.filter_map do
        Object.const_get(it) if Object.const_defined?(it)
      end
    end
  end
end
