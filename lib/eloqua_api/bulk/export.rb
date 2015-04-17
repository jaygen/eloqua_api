module Eloqua
  module Export
    def define_export(export)
      post("contact/export", export)
    end
    
    def retrieve_export(export_uri, options={})
      options[:page] ||= 1
      options[:pageSize] ||= 50000

      get("%s/data" % export_uri, options)
    end

    #
    # Version 2.0 of the Bulk API
    #
    def define_activity_export(export)
      post("activities/exports", export)
    end
    alias :define_activities_export :define_activity_export

    def retrieve_activity_export(export_uri, options={})
      options[:limit] ||= 50000

      get("%s/data" % export_uri, options)
    end
    alias :retrieve_activities_export :retrieve_activity_export

    def delete_export_definition(export_uri, options={})
      delete(export_uri)
    end

    def delete_export(export_uri, options={})
      delete("%s/data" % export_uri)
    end
  end
end
