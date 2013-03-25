require 'json'
require 'httparty'

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
    #debug_output $stdout
  end

  class Client
    BASE_URI = 'https://secure.eloqua.com'
    BASE_LOGIN_URI = 'https://login.eloqua.com'
    BASE_VERSION = '1.0'
    BASE_PATH = '/API/'

    attr_reader :site, :username, :url, :options, :version

    def initialize(site, username, password, opts={})
      @site = site
      @username = username
      @password = password
      @url = URI.parse(opts.delete(:url) || BASE_URI)
      @url_changed = false
      @version = opts.delete(:version) || BASE_VERSION
      @login_fallback = opts.delete(:login_fallback) || false
      @options = opts
    end

    def url_changed?
      @url_changed
    end

    def build_path(*segments)
      File.join(BASE_PATH, *segments.shift, version, *segments)
    end

    def login
      @url_changed = false

      uri = BASE_URI

      result = http(BASE_LOGIN_URI).get('/id')
      if result.code == 200 and result.parsed_response.is_a? Hash
        uri = result.parsed_response["urls"]["base"]
        @url_changed = true
      end

      @url = URI.parse(uri)

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

    def request(method, path, params, login_fallback=true)
      @http ||= http

      result = @http.send(method, path, params)
      if login_fallback and result.code == 401 and login and url_changed?
        request(method, path, params, false)
      else
        result
      end
    end

    def http(url=nil)
      site     = @site
      username = @username
      password = @password
      url    ||= @url

      Class.new(HTTPClient) do |klass|
        klass.base_uri(url.to_s) if url
        klass.basic_auth("%s\\%s" % [site, username], password)
      end
    end
  end
end

