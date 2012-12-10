module Eloqua
  class BulkClient < Client
    BULK_API_PATH = "/API/Bulk/1.0"

    def bulk_path(path)
      BULK_API_PATH + '/' + path
    end

    # convenience methods
    def define_export(export_definition)
      post(bulk_path("contact/export"), export_definition)
    end

    def sync(export_uri)
      post(bulk_path("sync"), {"syncedInstanceUri" => export_uri}.to_json)
    end

    def sync_status(sync_uri)
      get(bulk_path(sync_uri))
    end

    def retrieve_export(export_uri, options={})
      options[:page] ||= 1
      options[:page_size] ||= 50000

      get(bulk_path("#{export_uri}/data?page=#{options[:page]}&pageSize=#{options[:page_size]}"))
    end
  end
end