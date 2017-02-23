require 'metaractor'
require 'docker-api'

module Schmooze
  class WaitForDocker
    include Metaractor

    required :handler

    def call
      Logger.tagged('WaitForDocker') do
        Logger.info '==> Waiting for Docker...'
        begin
          Docker.ping
        rescue => e
          Logger.warn "Warning: #{e.message}; retrying"
          sleep 1
          retry
        end

        Logger.info '==> Docker is up!'
        handler.call
      end
    end

    private
    def handler
      context.handler
    end
  end
end
