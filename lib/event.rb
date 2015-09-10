require 'restful_model'

module Inbox
  class Event < RestfulModel

    parameter :title
    parameter :description
    parameter :location
    parameter :read_only
    parameter :participants
    parameter :when
    parameter :calendar_id
    parameter :namespace_id
    parameter :recurrence
    parameter :status
    parameter :master_event_id
    parameter :original_start_time
    parameter :busy

    def as_json(options = {})
      hash = super(options)

      # Delete nil values from the hash
      hash.delete_if { |key, value| value.nil? }

      # The API doesn't like to receive: "object": "timespan" in the when block.
      if hash.has_key?('when') and hash['when'].has_key?('object')
        hash['when'].delete('object')
      end

      return hash
    end

    def rsvp!(status, comment)
      url = @_api.url_for_path("/send-rsvp")
      data = {:event_id => @id, :status => status, :comment => comment}

      ::RestClient.post(url, data.to_json, :content_type => :json) do |response, request, result|
        json = Inbox.interpret_response(result, response, :expected_class => Object)
        self.inflate(json)
      end

      self
    end


  end
end
