require 'metaractor'
require 'docker-api'

module Schmooze
  class MonitorDockerEvents
    include Metaractor

    required :handler

    def call
      Logger.tagged('MonitorDockerEvents') do
        Logger.info "==> Monitoring docker events..."
        begin
          filters = {type: [:network], event: [:create]}.to_json
          Docker::Event.stream(filters: filters) do |event|
            handler.call(event)
          end
        rescue Docker::Error::TimeoutError
          retry
        rescue Excon::Errors::SocketError => e
          if Errno::ENOENT === e.cause
            raise
          else
            Logger.warn "Warning: #{e.message}; retrying"
            Logger.warn e.backtrace.join("\n")
            retry
          end
        end
      end
    end

    private
    def handler
      context.handler
    end
  end
end
