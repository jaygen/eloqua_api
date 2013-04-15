require 'json'
require 'httparty'
require 'uri'
require 'cgi'

module Eloqua
  class HTTPClient
    include HTTParty

    class Parser::CustomJSON < HTTParty::Parser
      def parse
        JSON.parse(body)
      rescue JSON::ParserError
        body
      end
    end
    parser Parser::CustomJSON

    headers 'User-Agent' => 'Kapost Eloqua API Client'
    format :json
  end

  class Client
    SITE = 'eloqua.com'
   # BASE_URI = "http://127.0.0.1:9393"
   # BASE_LOGIN_URI = "http://127.0.0.1:9393"
    BASE_URI = "https://secure.#{SITE}"
    BASE_LOGIN_URI = "https://login.#{SITE}"
    BASE_VERSION = '1.0'
    BASE_PATH = '/API/'

    AUTHORIZE_PATH = '/auth/oauth2/authorize'
    TOKEN_PATH = '/auth/oauth2/token'

    attr_reader :opts

    def initialize(opts={})
      @opts = opts.dup
      @opts[:url] ||= BASE_URI
      @opts[:version] ||= BASE_VERSION
      @url_changed = false
    end

    def version
      @opts[:version]
    end

    def authorize_url(options={})
      query = {}
      query[:response_type] = 'code'
      query[:client_id]     = @opts[:client_id]
      query[:redirect_uri]  = escape_uri(options[:redirect_uri] || @opts[:redirect_uri])
      query[:scope]         = options[:scope] || @opts[:scope] || 'full'

      if (state=(options[:state] || @opts[:state]))
        query[:state] = state
      end

      "#{BASE_URI}#{AUTHORIZE_PATH}?#{query.map { |k,v| [k, v].join('=') }.join('&')}"
    end

    def exchange_token(options={})
      auth = [@opts[:client_id], @opts[:client_secret]]

      body = {}
      if options[:code] and @opts[:redirect_uri]
        body[:grant_type]   = 'authorization_code'
        body[:code]         = options[:code]
        body[:redirect_uri] = escape_uri(@opts[:redirect_uri])
      elsif @opts[:refresh_token]
        body[:grant_type]   = 'refresh_token'
        body[:refresh_token] = @opts[:refresh_token]
      else
        raise ArgumentError, 'code and redirect_uri or refresh_token is required'
      end

      result = http(BASE_LOGIN_URI, auth).post(TOKEN_PATH, :body => body)
      if result.code == 200 and result.parsed_response.is_a? Hash
        @opts[:access_token] = result.parsed_response['access_token']
        @opts[:refresh_token] = result.parsed_response['refresh_token']
        @http = nil
      end

      result
    end

    def url
      @opts[:url]
    end

    def url_changed?
      @url_changed
    end

    def build_path(*segments)
      File.join(BASE_PATH, *segments.shift, version, *segments)
    end

    def login
      @http = nil

      uri = BASE_URI
      result = http(BASE_LOGIN_URI).get('/id')
      if result.code == 200 and result.parsed_response.is_a? Hash
        uri = result.parsed_response["urls"]["base"]
      end

      @url_changed = (uri != @opts[:url])
      @opts[:url] = uri if @url_changed

      result
    end

    def get(path, query={})
      request(:get, build_path(path), :query => query)
    end

    def post(path, body={})
      request(:post, build_path(path), :body => body)
    end

    def put(path, body={})
      request(:put, build_path(path), :body => body)
    end

    def delete(path)
      request(:delete, build_path(path))
    end

    protected

    def escape_uri(url)
      URI.escape(URI.unescape(url))
    end

    def request(method, path, params, login_fallback=true)
      @http ||= http

      result = @http.send(method, path, params)
      if login_fallback and result.code == 401 and login and url_changed?
        request(method, path, params, false)
      else
        result
      end
    end

    def http(url=nil, auth=nil)
      url ||= @opts[:url]
      auth ||= begin
        if @opts[:access_token]
          @opts[:access_token]
        elsif (site=@opts[:site]) and (username=@opts[:username]) and (password=@opts[:password])
          ["%s\\%s" % [site, username], password]
        else
          nil
        end
      end

      Class.new(HTTPClient) do |klass|
        klass.base_uri(url.to_s) if url

        if auth.is_a?(String) and auth.size > 0
          klass.headers("Authorization" => "Bearer %s" % auth)
        elsif auth.is_a?(Array) and auth.size == 2
          klass.basic_auth(*auth)
        end
      end
    end
  end
end

