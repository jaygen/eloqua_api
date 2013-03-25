module Eloqua
  module Campaign
    def get_campaign(campaign_id, options={})
      get("assets/campaign/%s" % campaign_id, options)
    end

    def get_recent_campaigns(options={})
      options[:count] ||= 10
      options[:depth] ||= "minimal"
      
      get("assets/campaigns/recent", options)
    end

    def get_campaigns(options={})
      options[:count] ||= 10
      options[:depth] ||= "minimal"
      options[:orderBy] ||= "createdAt+DESC"

      get("assets/campaigns", options)
    end
  end
end
