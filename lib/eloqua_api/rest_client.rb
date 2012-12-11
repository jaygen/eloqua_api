module Eloqua
  class RESTClient < Eloqua::Client
    REST_API_PATH = "/API/REST/1.0"

    def rest_path(path)
      REST_API_PATH + '/' + path
    end

    # convenience methods
    def create_segment(segment_definition)
      # debugger
      post(rest_path("assets/contact/segment"), segment_definition)
    end

    def get_segment(segment_id)
      get(rest_path("assets/contact/segment/#{segment_id}"))
    end
    
    def get_campaign(campaign_id)
      get(rest_path("assets/campaign/#{campaign_id}"))
    end
    
    def get_recent_campaigns(options={})
      options["count"] ||= 10
      options["depth"] ||= "minimal"
      get(rest_path("assets/campaigns/recent?count=#{options["count"]}&depth=#{options["depth"]}"))
    end

    def contact_activity(contact_id, options={})
      options["start_date"] ||= 1.year.ago.to_i
      options["end_date"] ||= Time.now.to_i
      options["type"] ||= "webVisit"
      options["count"] ||= 1000

      get(rest_path("data/activities/contact/#{contact_id}?startDate=#{options["start_date"]}&endDate=#{options["end_date"]}&type=#{options["type"]}&count=#{options["count"]}"))
    end
  end
end
