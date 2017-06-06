require 'concurrent'
require 'concurrent-edge'
require 'schmooze/wait_for_docker'

module Schmooze
  class WaitForDockerActor < Concurrent::Actor::RestartingContext
    def initialize(handler:)
      @handler = handler

      tell :wait_for_docker
    end

    def on_message(message)
      if message == :wait_for_docker
        Logger.tagged('WaitForDocker') do
          begin
            WaitForDocker.call!(
              handler: @handler
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
