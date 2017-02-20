require 'metaractor'

module Schmooze
  class AllowBridge
    include Metaractor

    required :bridge_name

    def call
      Logger.info "==> Allowing traffic to bridge network #{bridge_name}"
      Logger.info "==> Done"
    end

    private
    def bridge_name
      context.bridge_name
    end
  end
end
