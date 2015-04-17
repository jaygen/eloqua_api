require 'eloqua_api/bulk/export'
require 'eloqua_api/bulk/sync'
require 'eloqua_api/bulk/query'

module Eloqua
  class BulkClient < Client
    include Export
    include Sync

    def query(name)
      Query.new(name, self)
    end

    def build_path(*segments)
      super('/Bulk/', *segments)
    end
  end
end
