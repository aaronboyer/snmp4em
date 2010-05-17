# The SNMP4EM library 

module SNMP4EM
  class SnmpConnection
    @pending_requests = []
    @socket = nil
    
    class << self
      attr_reader :pending_requests
      attr_reader :socket
      
      def init_socket #:nodoc:
        if @socket.nil?
          @socket = EM::open_datagram_socket("0.0.0.0", 0, Handler)
        end
      end
    end
    
    attr_reader :host, :port, :timeout, :retries
    
    # Creates a new object to communicate with SNMPv1 agents. Optionally pass in the following parameters:
    # *  _host_ - IP/hostname of remote agent (default: 127.0.0.1)
    # *  _port_ - UDP port on remote agent (default: 161)
    # *  _community_ - Community string to use (default: public)
    # *  _community_ro_ - Read-only community string to use for get/getnext/walk operations (default: public)
    # *  _community_rw_ - Read-write community string to use for set operations (default: public)
    # *  _timeout_ - Number of seconds to wait before a request times out (default: 1)
    # *  _retries_ - Number of retries before failing (default: 3)
    
    def initialize(args = {})
      @host         = args[:host]         || "127.0.0.1"
      @port         = args[:port]         || 161
      @timeout      = args[:timeout]      || 1
      @retries      = args[:retries]      || 3
      
      self.class.init_socket
    end
    
    def send(message) #:nodoc:
      self.class.socket.send_datagram message.encode, @host, @port
    end
  end
end