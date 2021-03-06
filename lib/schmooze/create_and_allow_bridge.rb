require 'metaractor'
require 'schmooze/create_bridge'
require 'schmooze/allow_bridge'

module Schmooze
  class CreateAndAllowBridge
    include Metaractor
    include Interactor::Organizer

    required :bridge_name
    required :subnet, :ip_range

    organize [
      CreateBridge,
      AllowBridge
    ]
  end
end
