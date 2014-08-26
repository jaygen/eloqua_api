module Eloqua
  #
  # Usage:
  #
  # client = Eloqua::BulkClient.new({ ...  })
  # client.query("My Query/Export Name").
  #        select("Activity.Asset.Id AS AssetId", "Activity.Id AS ActivityId").
  #        from("activities").
  #        where("Activity.CreatedAt > 2014-08-01", "Activity.Type = EmailOpen").
  #        limit(3).
  #        retain(3600).
  #        execute().
  #        wait(30).each do |row|
  #           puts row
  #        end
  # 
  # If anything goes wrong (at any stage of the chain) a Query::Error exception will be thrown 
  # with a human readable error message, accompanied by the full HTTP request response and code 
  # when appropriate.
  #

  class Query
    class Error < StandardError
      attr_reader :code

      def initialize(message, code=500)
        @code = code
        super(message)
      end
    end

    def initialize(name, client)
      @name = name
      @client = client
      @fields = {}
      @filter = []
      @retain = 0
      @resource = nil
      @limit = 50000
      @uri = nil
      @sync = false
    end

    def delete
      raise Error, 'Execute must be called before calling delete.' if @uri.nil?
      
      client.delete_export(@uri)
      client.delete_export_definition(@uri)

      self
    end

    def execute
      raise Error, 'Execute cannot be called more than once.' unless @uri.nil?
      raise Error, 'A valid resource must be defined before calling execute.' unless @resource and @client.respond_to?(define_export_method) and @client.respond_to?(retrieve_export_method)

      response = @client.send(define_export_method, to_h)
      if response.code == 201 and response.parsed_response['uri']
        @uri = response.parsed_response['uri']
      else
        raise Error.new("Could not execute query because: #{response.parsed_response.to_s}.", response.code)
      end

      self
    end

    def wait(secs)
      raise Error, 'Execute must be called before wait.' if @uri.nil?

      response = nil
      @sync_uri ||= nil

      if @sync_uri.nil?
        response = @client.syncs(@uri)
        if response.code == 201 and response.parsed_response['status'] == 'pending'
          @sync_uri = response.parsed_response['uri']
        else
          raise Error.new("Could not sync because: #{response.parsed_response.to_s}.", response.code)
        end
      end

      i = 0
      while i < secs
        i += 1

        response = @client.syncs_status(@sync_uri)
        if response.code == 200 and response.parsed_response['status'] == "success"
          @sync = true
          return self
        end

        sleep 1
      end

      raise Error.new("Could not sync in #{secs} seconds, because: #{response.parsed_response.to_s}.", response.code) unless response.nil?

      self
    end

    def count
      raise Error, 'Wait must be called before calling count.' unless @sync

      response = @client.send(retrieve_export_method, @uri, :limit => @limit)
      if response.code == 200 and response.parsed_response['totalResults']
        response.parsed_response['totalResults'].to_i
      else
        raise Error.new("Could not call count because: #{response.parsed_response.to_s}.", response.code)
      end
    end

    def each
      raise Error, 'No block provided.' unless block_given?
      raise Error, 'Wait must be called before calling each.' unless @sync

      offset = 0
      while true
        response = @client.send(retrieve_export_method, @uri, :offset => offset, :limit => @limit)
        if response.code == 200 and response.parsed_response['totalResults']
          response = response.parsed_response

          response['items'].each do |item|
            yield item
          end

          if response['hasMore']
            offset += @limit
          else
            break
          end
        else
          raise Error.new("Could not call each because: #{response.parsed_response.to_s}.", response.code)
        end
      end

      self
    end

    def to_h
      hash = {}
      hash['name'] = @name
      hash['fields'] = @fields
      hash['filter'] = @filter.join(' ')
      hash['secondsToRetainData'] = @retain if @retain > 0
      hash
    end

    def limit(n)
      @limit = n.to_i
      self
    end

    def from(resource)
      @resource = resource.downcase if resource.is_a?(String)
      self
    end

    def retain(secs)
      @retain = secs.to_i
      self
    end

    def select(*selectors)
      fields = {}

      selectors.each do |field|
        l, op, r = expression(field)
        if not op.nil? and op.upcase == 'AS'
          fields[r] = "{{#{l}}}"
        elsif op.nil?
          fields[field.gsub('.', '')] = "{{#{field}}}"
        end
      end

      @fields.merge!(fields) if fields.any?

      self
    end

    def where(*conditions)
      filter = []
      
      conditions.each do |condition|
        l, op, r = expression(condition)
        filter << "'{{#{l}}}'#{op.upcase}'#{r}'" if l
      end

      if filter.any?
        if block_given?
          @filter << yield(filter.join(" AND "))
        else
          @filter << filter.join(" AND ")
        end
      end

      self
    end

    def or(*conditions)
      where(*conditions) do |filter|
        "OR ( #{filter} )"
      end

      self
    end

    protected

    def define_export_method
      @define_export_method ||= :"define_#{@resource}_export"
    end

    def retrieve_export_method
      @retrieve_export_method ||= :"retrieve_#{@resource}_export"
    end

    def expression(condition)
      if condition =~ /^(.*?)\s+(.*?)\s+(.*?)$/
        [$1, $2, $3]
      else
        [nil, nil, nil]
      end
    end
  end
end
