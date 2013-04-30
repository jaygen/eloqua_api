module Eloqua
  module ImportedFile
    def create_imported_file(file, content_type=nil)
      post("assets/importedFile/content", :file => file_to_upload_io(file, content_type))
    end

    def replace_imported_file(id, file, content_type=nil)
      post("assets/importedFile/%s/content/replace" % id, :file => file_to_upload_io(file, content_type))
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

    protected

    def file_to_upload_io(file, content_type)
      file.is_a?(UploadIO) ? file : UploadIO.new(file, content_type)
    end
  end
end
