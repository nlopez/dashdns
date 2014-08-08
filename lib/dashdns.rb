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

      match(domain, IN::SOA) do |txn|
        txn.respond!(
          Name.create("ns1.#{domain}."),        # Master Name
          Name.create("hostmaster.#{domain}."), # REsponsible Name
          File.mtime(__FILE__).to_i,            # Serial Number
          86400,                                # Refresh Time
          7200,                                 # Retry Time
          604800,                               # Maximum TTL / Expirty Time
          86400                                 # Minimum TTL
        )

        txn.append!(txn.question, IN::NS, :section => :authority)
      end

      match(domain, IN::NS) do |txn|
        txn.respond!(Name.create("ns1.#{domain}."), :ttl => 300)
        txn.respond!(Name.create("ns2.#{domain}."), :ttl => 300)
      end

      match(/^(.*)\.#{domain}$/, IN::A) do |transaction, match_data|
      logger.debug(match_data.string)
        case match_data[1]
        when 'ns1'
          transaction.respond!('54.210.219.88')
        when 'ns2'
          transaction.respond!('54.210.230.17')
        when /((\d+)-){3}(\d+)/
          match = match_data.to_s.chomp(".#{domain}").gsub('-', '.')
          begin
            ip = IPAddr.new(match)
            transaction.respond!(ip.to_s, :ttl => 86400)
          rescue StandardError => e
            transaction.fail!(:NXDomain)
            logger.error(e.message)
            logger.debug(match_data.string)
          end
        else
          transaction.fail!(:NXDomain)
        end
      end
    end
  end
end
