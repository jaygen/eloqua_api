module Eloqua
  module User
    def get_users(options={})
      options[:count] ||= 10
      options[:depth] ||= "minimal"

      get("system/users", options)
    end
  end
end
