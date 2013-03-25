module Eloqua
  module Segment
    def create_segment(segment)
      post("assets/contact/segment", segment)
    end

    def get_segment(id)
      get("assets/contact/segment/%s" % id)
    end
  end
end
