module Eloqua
  module Contact
    def get_contacts(options={})
      options[:count] ||= 10
      options[:depth] ||= "minimal"

      get("data/contacts", options)
    end

    def contact_activity(contact_id, options={})
      options[:startDate] ||= 1.year.ago.to_i
      options[:endDate] ||= Time.now.to_i
      options[:type] ||= "webVisit"
      options[:count] ||= 1000

      get("data/activities/contact/%s" % contact_id, options)
    end
  end
end
