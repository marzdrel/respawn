# frozen_string_literal: true

module Respawn
  class ExceptionDetector
    PREDEFINED_EXCEPTIONS = [
      EOFError,
      Errno::ECONNABORTED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
    ].freeze

    DYNAMIC_EXCEPTIONS = [
      "SocketError",
      "Faraday::ConnectionFailed",
      "Faraday::TimeoutError",
      "Faraday::ClientError",
      "Faraday::ServerError",
      "Net::OpenTimeout",
      "Net::ReadTimeout",
      "OpenSSL::SSL::SSLError",
      "OpenURI::HTTPError",
    ].freeze

    def self.call(...)
      new(...).call
    end

    def call
      PREDEFINED_EXCEPTIONS + dynamic_exceptions
    end

    def dynamic_exceptions
      DYNAMIC_EXCEPTIONS.filter_map do
        Object.const_get(it) if Object.const_defined?(it)
      end
    end
  end
end
