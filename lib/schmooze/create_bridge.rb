require 'metaractor'

module Schmooze
  class CreateBridge
    include Metaractor

    required :bridge_name

    def call
      Logger.info "==> Ensuring bridge network #{bridge_name} exists"
      Logger.info "==> Done"
    end

    private
    def bridge_name
      context.bridge_name
    end
  end
end
