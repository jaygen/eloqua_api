require 'net/https'

module Eloqua
  class Client
    attr_reader :site, :user

    def initialize(site=nil, user=nil, password=nil)
      @site = site
      @user = user
      @password = password

      @https = Net::HTTP.new('secure.eloqua.com', 443)
      @https.use_ssl = true
      @https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    METHODS = {
            :get    => ::Net::HTTP::Get,
            :post   => ::Net::HTTP::Post,
            :put    => ::Net::HTTP::Put,
            :delete => ::Net::HTTP::Delete
          }

    def delete(path)
      request(:delete, path)
    end

    def get(path)
      request(:get, path)
    end

    def post(path, body={})
      request(:post, path, body)
    end

    def put(path, body={})
      request(:put, path, body)
    end

    def request(method, path, body={})
      request = METHODS[method].new(path, {'Content-Type' =>'application/json'})
      request.basic_auth @site + '\\' + @user, @password

      case method
        when :post, :put
          request.body = body
      end

      response = @https.request(request)
      return response
    end
  end
end