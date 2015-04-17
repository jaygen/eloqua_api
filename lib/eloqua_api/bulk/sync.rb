module Eloqua
  module Sync
    def sync(export_uri, options={})
      options[:syncedInstanceUri] ||= export_uri
      post("sync", options)
    end

    def sync_status(sync_uri, options={})
      get(sync_uri, options)
    end

    # 
    # Version 2.0 of the Bulk API changed this endpoint
    # from sync to syncs.
    #
    def syncs(export_uri, options={})
      options[:syncedInstanceUri] ||= export_uri
      post("syncs", options)
    end

    alias :syncs_status :sync_status
  end
end
