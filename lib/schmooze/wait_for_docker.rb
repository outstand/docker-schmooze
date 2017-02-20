require 'metaractor'

module Schmooze
  class WaitForDocker
    include Metaractor

    required :handler

    def call
      Logger.tagged('WaitForDocker') do
        Logger.info '==> Waiting for Docker...'
        sleep 5
        handler.call
      end
    end

    private
    def handler
      context.handler
    end
  end
end
