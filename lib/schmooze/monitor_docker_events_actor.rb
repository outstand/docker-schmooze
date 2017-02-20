require 'concurrent'
require 'concurrent-edge'
require 'schmooze/monitor_docker_events'

module Schmooze
  class MonitorDockerEventsActor < Concurrent::Actor::RestartingContext
    def initialize(event_handler:)
      @event_handler = event_handler
    end

    def on_message(message)
      if message == :monitor
        Logger.tagged('MonitorDockerEvents') do
          begin
            MonitorDockerEvents.call!(
              container_name: @container_name,
              handler: @event_handler
            )
          rescue Excon::Errors::SocketError => e
            if Errno::ENOENT === e.cause
              Logger.warn "Warning: #{e.cause.message}; retrying in 30 seconds"
              Logger.warn e.backtrace.join("\n")
              Concurrent::ScheduledTask.execute(30){ tell :monitor }
            end
          end
        end

        nil
      else
        pass
      end
    end
  end
end
