module SNMP4EM
  
  # This implements EM::Deferrable, so you can hang a callback() or errback() to retrieve the results.

  class SnmpGetRequest < SnmpRequest
    attr_accessor :snmp_id

    # For an SNMP-GET request, @pending_oids will be a ruby array of SNMP::ObjectNames that need to be fetched. As
    # responses come back from the agent, this array will be pruned of any error-producing OIDs. Once no errors
    # are returned, the @responses hash will be populated and returned.

    def handle_response(response) #:nodoc:
      super
      
      if response.error_status == :noError
        pending_oids.zip(response.varbind_list).each do |oid, response_vb|
          oid[:response] = format_value(response_vb)
          oid[:state] = :complete
        end
      
      else
        error_oid = pending_oids[response.error_index - 1]
        error_oid[:state] = :error
        error_oid[:error] = SNMP::ResponseError.new(response.error_status)
      end

      if pending_oids.empty?
        result = {}

        @oids.each do |oid|
          requested_oid = oid[:requested_string]
          result[requested_oid] = oid[:error] || oid[:response]
        end

        succeed result
        return
      end
    
      send
    end

    private

    def send
      Manager.track_request(self)

      query_oids = @oids.select{|oid| oid[:state] == :pending}.collect{|oid| oid[:requested_oid]}

      vb_list = SNMP::VarBindList.new(query_oids)
      request = SNMP::GetRequest.new(@snmp_id, vb_list)
      message = SNMP::Message.new(@sender.version, @sender.community_ro, request)

      super(message)
    end
  end  
end
