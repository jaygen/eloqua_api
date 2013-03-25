module Eloqua
  module Microsite
    def get_micro_site(id)
      get("assets/microsite/%s" % id)
    end
  end
end
