# Encoding: utf-8
require 'rubydns'
require 'ipaddr'

class Dashdns
  INTERFACES = [
      [:udp, '0.0.0.0', 5300],
      [:tcp, '0.0.0.0', 5300]
  ]

  Name = Resolv::DNS::Name
  IN = Resolv::DNS::Resource::IN

  def initialize(domain)
    @domain = domain
  end

  def run
    domain = @domain
    RubyDNS.run_server(listen: INTERFACES) do
      match(/^((\d+)-){3}(\d+)\.#{domain}$/, IN::A) do |transaction, match_data|
        match = match_data.to_s.chomp(".#{domain}").gsub('-', '.')
        begin
          ip = IPAddr.new(match)
          transaction.respond!(ip.to_s, :ttl => 86400)
        rescue StandardError => e
          transaction.fail!(:NXDomain)
          logger.error(e.message)
          logger.debug(match_data.string)
        end
      end

      otherwise do |transaction|
        transaction.fail!(:NXDomain)
      end
    end
  end
end
