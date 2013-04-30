require 'eloqua_api/rest/segment'
require 'eloqua_api/rest/landing_page'
require 'eloqua_api/rest/email'
require 'eloqua_api/rest/campaign'
require 'eloqua_api/rest/contact'
require 'eloqua_api/rest/user'
require 'eloqua_api/rest/microsite'
require 'eloqua_api/rest/imported_file'

module Eloqua
  class RESTClient < Client
    include Segment
    include LandingPage
    include Email
    include Campaign
    include Contact
    include User
    include Microsite
    include ImportedFile

    def build_path(*segments)
      super('/REST/', *segments)
    end
  end
end
