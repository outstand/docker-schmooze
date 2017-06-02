require 'metaractor'
require 'tty-command'

module Schmooze
  class AllowBridge
    include Metaractor

    required :bridge_name

    def call
      Logger.info "==> Allowing traffic to bridge network #{bridge_name}"

      cmd = TTY::Command.new
      if cmd.run!("iptables -C FORWARD -i #{bridge_name} -j ACCEPT 2> /dev/null").success?
        cmd.run("iptables -D FORWARD -i #{bridge_name} -j ACCEPT")
      end
      cmd.run("iptables -I FORWARD -i #{bridge_name} -j ACCEPT")

      if cmd.run!("iptables -C FORWARD -o #{bridge_name} -j ACCEPT 2> /dev/null").success?
        cmd.run("iptables -D FORWARD -o #{bridge_name} -j ACCEPT")
      end
      cmd.run("iptables -I FORWARD -o #{bridge_name} -j ACCEPT")

      Logger.info "==> Done"
    end

    private
    def bridge_name
      context.bridge_name
    end
  end
end
