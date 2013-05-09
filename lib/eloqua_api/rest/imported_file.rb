module Eloqua
  module ImportedFile
    def create_imported_file(file)
      multipart_post("assets/importedFile/content", file)
    end

    def replace_imported_file(id, file)
      multipart_post("assets/importedFile/%s/content/replace" % id, file)
    end

    def get_imported_file(id, options={})
      get("assets/importedFile/%s" % id, options)
    end

    def update_imported_file(id, file)
      put("assets/importedFile/%s" % id, file)
    end

    def delete_imported_file(id)
      delete("assets/importedFile/%s" % id)
    end

    def imported_file_folder(id, options={})
      options[:depth] ||= 'minimal'

      get("assets/importedFile/folder/%s" % id, options)
    end

    def imported_file_folder_folders(id, options={})
      options[:count] ||= 10
      options[:depth] ||= 'minimal'

      get("assets/importedFile/folder/%s/folders" % id, options)
    end

    def imported_file_folders(options={})
      options[:count] ||= 10
      options[:depth] ||= 'minimal'

      get("assets/importedFile/folders", options)
    end
  end
end
