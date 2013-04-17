module Eloqua
  module Email
    def create_email(email)
      post("assets/email", email)
    end

    def delete_email(id)
      delete("assets/email/%s" % id)
    end

    def get_email(id, options={})
      get("assets/email/%s" % id, options)
    end

    def get_email_preview(id, options={})
      get("assets/email/%s/preview" % id, options)
    end

    def get_recent_emails(options={})
      options[:count] ||= 10
      options[:depth] ||= "minimal"
      
      get("assets/emails/recent", options)
    end

    def get_emails(options={})
      options[:count] ||= 10
      options[:depth] ||= "minimal"
      options[:orderBy] ||= "createdAt+DESC"

      get("assets/emails", options)
    end 

    def get_email_template(id, options={})
      get("assets/email/template/%s" % id, options={})
    end

    def get_email_templates(options={})
      get("assets/templates/email", options)
    end
  end
end
