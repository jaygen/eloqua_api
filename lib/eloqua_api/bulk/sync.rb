module Eloqua
  module Sync
    def sync(export_uri, options={})
      options[:syncedInstanceUri] ||= export_uri
      post("sync", options.to_json)
    end

    def sync_status(sync_uri, options={})
      get(sync_uri, options)
    end
  end
end
