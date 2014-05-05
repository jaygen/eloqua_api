module Eloqua
  module LandingPage
    def create_landing_page(page)
      post("assets/landingPage", page)
    end

    def delete_landing_page(id)
      delete("assets/landingPage/%s" % id)
    end

    def validate_landing_page(id, options={})
      get("assets/landingPage/%s/active/validationErrors" % id)
    end

    def activate_landing_page(id, options={})
      post("assets/landingPage/%s/active" % id, options)
    end

    def get_landing_page(id)
      get("assets/landingPage/%s" % id)
    end

    def get_landing_page_preview(id, options={})
      get("assets/landingPage/%s/preview" % id, options)
    end

    def get_recent_landing_pages(options={})
      options[:count] ||= 10
      options[:depth] ||= "minimal"
      
      get("assets/landingPages/recent", options)
    end

    def get_landing_pages(options={})
      options[:count] ||= 10
      options[:depth] ||= "minimal"
      options[:orderBy] ||= "createdAt+DESC"

      get("assets/landingPages", options)
    end 

    def get_landing_page_template(id, options={})
      get("assets/landingPage/template/%s" % id, options)
    end

    def get_landing_page_templates(options={})
      get("assets/templates/landingpage", options)
    end
  end
end
