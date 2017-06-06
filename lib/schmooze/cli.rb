require 'thor'

module Schmooze
  class CLI < Thor
    desc 'version', 'Print out the version string'
    def version
      require 'schmooze/version'
      say Schmooze::VERSION.to_s
    end

    desc 'start', 'Start schmooze'
    option :bridge_name, aliases: '-b', required: true, type: :string
    option :subnet, required: true, type: :string
    option :ip_range, required: true, type: :string
    option :verbose, aliases: '-v', type: :boolean, default: false
    def start
      $stdout.sync = true
      require 'schmooze/run_schmooze'
      RunSchmooze.call(
        bridge_name: options[:bridge_name],
        subnet: options[:subnet],
        ip_range: options[:ip_range],
        verbose: options[:verbose]
      )
    end
  end
end
