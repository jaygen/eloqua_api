module Eloqua
  module Contact
    def find_contact_by_email(email, options={})
      options[:depth] ||= "minimal"
      options[:count] ||= 1
      options[:search] = email
      
      get("data/contacts", options)
    end

    def get_contact(contact_id, options={})
      options[:depth] ||= "minimal"
  
      get("data/contact/#{contact_id}", options)
    end
    
    def get_contact_fields(options={})
      options[:depth] ||= "minimal"

      get("assets/contact/fields", options)
    end
    
    def create_contact(data)
      post("data/contact", data)
    end
    
    def update_contact(contact_id, data)
      put("data/contact/#{contact_id}", data)
    end
    
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
