require "snmp4em"

class SNMP4EM::SnmpRequest
  def expect &block
    self.callback &block
    self.errback {|error| fail error}

    self.callback { EM.stop }
    self.errback  { EM.stop }
  end
end

RSpec.configure do |config|
  config.around :each do |spec|
    EM.run do
      @snmp = SNMP4EM::Manager.new(:port => 1620, :community_ro => "public", :community_rw => "private")
      spec.run
    end
  end
end