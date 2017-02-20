require 'concurrent'
require 'concurrent-edge'
require 'schmooze/create_and_allow_bridge'

module Schmooze
  class CreateAndAllowBridgeActor < Concurrent::Actor::RestartingContext
    def initialize(bridge_name:)
      @bridge_name = bridge_name
    end

    def on_message(message)
      if message == :create_and_allow
        Logger.tagged('CreateAndAllowBridge') do
          begin
            CreateAndAllowBridge.call!(bridge_name: @bridge_name)
          rescue => e
            Logger.warn "Warning: #{e.cause.message}; retrying in 30 seconds"
            Logger.warn e.backtrace.join("\n")
            Concurrent::ScheduledTask.execute(5){ tell :create_and_allow }
          end
        end

        nil
      else
        pass
      end
    end
  end
end
