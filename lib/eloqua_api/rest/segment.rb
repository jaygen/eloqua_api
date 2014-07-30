module Eloqua
  module Segment
    def create_segment(segment)
      post("assets/contact/segment", segment)
    end

    def create_segment_queue(segment)
      post("assets/contact/segment/queue/%s" % segment)
    end

    def get_segment(id)
      get("assets/contact/segment/%s" % id)
    end
  end
end
