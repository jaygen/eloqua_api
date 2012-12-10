Eloqua
============

Ruby wrapper for the Eloqua REST and Bulk APIs.  

Uses basic authentication and always hits secure.eloqua.com # FIXME!

Installation
------------

Add to your Gemfile:

```ruby
gem 'eloqua'
```

Example
-----

Get a contact's details:

```ruby
client = Eloqua::RESTClient.new("E10PartnerPlayground", "some_user", "some_pw")
client.contact_activity(1234)
```

Note on patches/pull requests
------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself in another branch so I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

