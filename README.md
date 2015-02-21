Eloqua
===

Ruby wrapper for the Eloqua REST and Bulk APIs.  

Uses basic authentication and always hits secure.eloqua.com # FIXME!

Installation
---

Add to your Gemfile:

```ruby
gem 'eloqua_api'
```

RESTClient BasicAuth Example
---

Get a contact's details:

```
client = Eloqua::RESTClient.new(site:     "some_site",
                                username: "some_user",
                                password: "some_pw")
client.contact_activity(1234)
```

BulkClient BasicAuth Example
---

```
client = Eloqua::BulkClient.new(site:     "some_site",
                                username: "some_user",
                                password: "some_pw")
query = client.query("Some EloquaAPI Test Query")
query.select(...).from(...).where(...).limit(...).retain(...).execute()

```

RESTClient OAuth2 Example
---

Get Eloqua OAuth2 tokens:

(Example written as a complete sinatra web app)

```
require 'sinatra'
require 'eloqua_api'

post '/enable' do
  redirect(eloqua_client.authorize_url, 302)
end

get '/configure/:installid' do
  eloqua_client.exchange_token({
    code: params['code']
  })
  redirect(params['callback'])
end

def eloqua_client
  client = Eloqua::RESTClient.new({
    client_id: "some_client_id",
    client_secret: "some_client_secret",
    redirect_uri: "https://#{request.host}/configure/#{params['installid']}?callback=#{URI::escape(params['callback'])}"
  })
  client.on_authorize = Proc.new do |data|
    logger.info("Eloqua Authorized")
    logger.info(data)
    # TODO: store 'data' containing the tokens for future use
  end
  client
end
```

Note on patches/pull requests
---

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself in another branch so I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

