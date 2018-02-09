require 'metaractor'

module Schmooze
  class CreateBridge
    include Metaractor

    required :bridge_name
    required :subnet, :ip_range

    def call
      Logger.tagged('CreateBridge') do
        Logger.info "==> Ensuring bridge network #{bridge_name} exists"

        begin
          Docker::Network.create(
            bridge_name,
            'Driver' => 'bridge',
            'IPAM' => {
              'Config' => [
                {
                  'Subnet' => subnet,
                  'IPRange' => ip_range
                }
              ]
            },
            'Options' => {
              'com.docker.network.bridge.enable_icc'=> 'true',
              'com.docker.network.bridge.enable_ip_masquerade' => 'true',
              'com.docker.network.bridge.name' => bridge_name
            }
          )
        rescue Docker::Error::ServerError => e
          # Whitelist this error message
          raise if e.message != "network with name #{bridge_name} already exists\n"
        rescue Excon::Error::Forbidden => e
          raise if e.response.body != "network with name #{bridge_name} already exists\n"
        rescue Docker::Error::TimeoutError
          retry
        rescue Excon::Error::HTTPStatus => e
          message = StringIO.new
          Excon::PrettyPrinter.pp(message, e.response.data)
          Logger.warn "Response: #{message.string}"
          raise
        rescue Excon::Errors::SocketError => e
          if Errno::ENOENT === e.cause
            raise
          else
            Logger.warn "Warning: #{e.message}; retrying"
            Logger.warn e.backtrace.join("\n")
            retry
          end
        else
          Logger.info "Bridge Created."
        end

        Logger.info "==> Done"
      end
    end

    private
    def bridge_name
      context.bridge_name
    end

    def subnet
      context.subnet
    end

    def ip_range
      context.ip_range
    end
  end
end
