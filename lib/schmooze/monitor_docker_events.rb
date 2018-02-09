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
          filters = MultiJson.dump({type: [:network], event: [:create]})
          Docker::Event.stream(filters: filters) do |event|
            begin
              if event.actor.attributes['name'] == 'dns' &&
                  event.actor.attributes['type'] == 'bridge'
                Logger.info 'Ignoring dns bridge creation'
              else
                Logger.info event.to_s
                handler.call(event)
              end
            rescue => e
              Logger.warn "Warning: #{e.message}"
              Logger.warn e.backtrace.join("\n")
              raise
            end
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
