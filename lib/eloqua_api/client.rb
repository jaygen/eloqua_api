require 'json'
require 'httmultiparty'
require 'uri'
require 'cgi'

module Eloqua
  class HTTPClient
    include HTTMultiParty

    class Parser::CustomJSON < HTTParty::Parser
      def parse
        JSON.parse(body) if body
      rescue JSON::ParserError
        body
      end
    end
    parser Parser::CustomJSON

    headers 'User-Agent' => 'Kapost Eloqua API Client'
    headers 'Accept' => 'application/json'
    headers 'Content-Type' => 'application/json'

    query_string_normalizer proc { |query|
      qs = HashConversions.to_params(query)
      qs.gsub!(/orderBy=(.*?)%2B(.*?)(&|\?|$)/) do |m|
        "orderBy=#{$1}+#{$2}#{$3}"
      end
      qs
    }

    format :json
    # debug_output $stdout
  end

  class Client
    SITE = 'eloqua.com'
    BASE_URI = "https://secure.#{SITE}"
    BASE_LOGIN_URI = "https://login.#{SITE}"
    BASE_VERSION = '1.0'
    BASE_PATH = '/API/'

    AUTHORIZE_PATH = '/auth/oauth2/authorize'
    TOKEN_PATH = '/auth/oauth2/token'
    TOKEN_PATH_HEADERS = 
    {
      'Accept'          => 'application/json, text/javascript, */*; q=0.01',
      'Accept-Language' => 'en-US,en;q=0.5',
      'Content-Type'    => 'application/x-www-form-urlencoded; charset=UTF-8'
    }.freeze

    attr_reader :opts

    attr_accessor :on_authorize
    attr_accessor :on_refresh_token

    def initialize(opts={})
      @opts = opts.is_a?(Hash) ? opts.dup : {}
      @opts[:url] ||= BASE_URI
      @opts[:version] ||= BASE_VERSION
      @url_changed = false
      @token_refreshed = false
    end

    def version
      @opts[:version]
    end

    def authorize_url(options={})
      query = {}
      query[:response_type] = 'code'
      query[:client_id]     = @opts[:client_id]
      query[:scope]         = options[:scope] || @opts[:scope] || 'full'

      if (state=(options[:state] || @opts[:state]))
        query[:state] = state
      end

      query[:redirect_uri]  = escape_uri(options[:redirect_uri] || @opts[:redirect_uri])

      "#{BASE_LOGIN_URI}#{AUTHORIZE_PATH}?#{query.map { |k,v| [k, v].join('=') }.join('&')}"
    end

    def exchange_token(options={})
      auth = [@opts[:client_id], @opts[:client_secret]]

      body = {}
      if options[:code] and @opts[:redirect_uri]
        body[:grant_type]   = 'authorization_code'
        body[:code]         = options[:code]
        body[:redirect_uri] = escape_uri(@opts[:redirect_uri])
      elsif refresh_token?
        body[:grant_type]   = 'refresh_token'
        body[:refresh_token] = @opts[:refresh_token]
        body[:redirect_uri] = escape_uri(@opts[:redirect_uri])
      else
        raise ArgumentError, 'code and redirect_uri or refresh_token and redirect_uri is required'
      end

      result = http(BASE_LOGIN_URI, auth).post(TOKEN_PATH, :body => body, :headers => TOKEN_PATH_HEADERS)
      return result unless result.code == 200 and result.parsed_response.is_a? Hash

      response = result.parsed_response
      return result unless response['access_token'] and response['refresh_token']

      @opts[:access_token] = response['access_token']
      @opts[:refresh_token] = response['refresh_token']
        
      @http = nil
      @token_refreshed = true

      if refresh_token? and on_refresh_token?
        on_refresh_token.call(response)
      elsif options[:code] and @opts[:redirect_uri] and on_authorize?
        on_authorize.call(response)
      end

      result
    end

    def on_refresh_token?
      on_refresh_token.is_a? Proc
    end

    def on_authorize?
      on_authorize.is_a? Proc
    end

    def url
      @opts[:url]
    end

    def url_changed?
      @url_changed
    end

    def token_refreshed?
      @token_refreshed
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
      request(:post, build_path(path), :body => body.to_json)
    end

    def multipart_post(path, body={})
      request(:post, build_path(path), :body => body)
    end

    def put(path, body={})
      request(:put, build_path(path), :body => body.to_json)
    end

    def delete(path)
      request(:delete, build_path(path))
    end

    protected

    def refresh_token?
      @opts[:refresh_token] and 
      @opts[:redirect_uri]
    end

    def escape_uri(url)
      URI.escape(URI.unescape(url))
    end

    def request(method, path, params={}, login_fallback=true)
      @http ||= http

      result = @http.send(method, path, params)
      if result.code == 401 and login_fallback
        exchange_token if refresh_token?
        
        if login
          request(method, path, params, false)
        else
          result
        end
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

