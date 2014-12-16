module Paperclip
  class MediaTypeSpoofDetector
    # Добавляем проверку @file.size != 0, чтобы не проверять файлы, которые идут мимо бэкенда
    def spoofed?
      if @file.size != 0 && has_name? && has_extension? && media_type_mismatch? && mapping_override_mismatch?
        Paperclip.log("Content Type Spoof: Filename #{File.basename(@name)} (#{supplied_file_content_types}), content type discovered from file command: #{calculated_content_type}. See documentation to allow this combination.")
        true
      end
    end
  end
end
