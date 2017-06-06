require 'metaractor'
require 'concurrent'
require 'schmooze/logger'
require 'schmooze/create_and_allow_bridge_actor'
require 'schmooze/monitor_docker_events_actor'
require 'schmooze/wait_for_docker_actor'

module Schmooze
  class RunSchmooze
    include Metaractor

    required :bridge_name
    required :subnet, :ip_range
    optional :verbose

    before do
      context.verbose ||= false
    end

    def call
      Concurrent.use_stdlib_logger(Logger::DEBUG) if verbose

      self_read, self_write = IO.pipe
      %w(INT TERM).each do |sig|
        begin
          trap sig do
            self_write.puts(sig)
          end
        rescue ArgumentError
          puts "Signal #{sig} not supported"
        end
      end

      begin
        create_and_allow_actor = CreateAndAllowBridgeActor.spawn(
          :create_and_allow,
          bridge_name: bridge_name,
          subnet: subnet,
          ip_range: ip_range
        )

        monitor_docker_events_actor = MonitorDockerEventsActor.spawn(
          :monitor_docker_events,
          event_handler: ->(event) { create_and_allow_actor << :create_and_allow }
        )

        WaitForDockerActor.spawn(
          :wait_for_docker,
          handler: lambda do
            create_and_allow_actor << :create_and_allow
            monitor_docker_events_actor << :monitor
          end
        )

        while readable_io = IO.select([self_read])
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end

      rescue Interrupt
        Logger.info 'Exiting'
        # actors are cleaned up in at_exit handler
        exit 0
      end
    end

    private
    def handle_signal(sig)
      case sig
      when 'INT'
        raise Interrupt
      when 'TERM'
        raise Interrupt
      end
    end

    def bridge_name
      context.bridge_name
    end

    def subnet
      context.subnet
    end

    def ip_range
      context.ip_range
    end

    def verbose
      context.verbose
    end
  end
end
