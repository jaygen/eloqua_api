module Eloqua
  module User
    def get_user(id, options={})
      get("system/user/%s" % id, options)
    end

    def get_users(options={})
      options[:count] ||= 10
      options[:depth] ||= "minimal"

      get("system/users", options)
    end
  end
end
