require 'eloqua_api/bulk/export'
require 'eloqua_api/bulk/sync'

module Eloqua
  class BulkClient < Client
    include Export
    include Sync

    def build_path(*segments)
      super('/Bulk/', *segments)
    end
  end
end
