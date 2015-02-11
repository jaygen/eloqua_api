require "spec_helper"

require "eloqua_api"

describe Eloqua::Query do
  let(:site)     { ENV.fetch("ELOQUA_TEST_SITE")     }
  let(:username) { ENV.fetch("ELOQUA_TEST_USERNAME") }
  let(:password) { ENV.fetch("ELOQUA_TEST_PASSWORD") }

  let(:client) { Eloqua::BulkClient.new(url: "https://secure.p03.eloqua.com",
                                        version:  "2.0",
                                        site:     site,
                                        username: username,
                                        password: password) }

  let(:query)  { client.query("EloquaAPI Test Query") }

  describe "A full query" do
    it "should work" do
      expect {
        items = []
        query.select("Activity.Asset.Id AS AssetId", "Activity.Id AS ActivityId").
              from("activities").
              where("Activity.CreatedAt > 2014-08-01", "Activity.Type = EmailOpen").
              limit(3).
              retain(3600).
              execute().
              wait(30).each { |i| items << i }
        items
      }.to_not raise_error

    end
  end

end


