module Paperclip
  class Attachment
    def self.default_options
      @default_options ||= {
        :convert_options       => {},
        :default_style         => :original,
        :default_url           => "/:attachment/:style/missing.png",
        :escape_url            => true,
        :restricted_characters => /[&$+,\/:;=?@<>\[\]\{\}\|\\\^~%# ]/,
        :filename_cleaner      => nil,
        :hash_data             => ":class/:attachment/:id/:style/:updated_at",
        :hash_digest           => "SHA1",
        :interpolator          => Paperclip::Interpolations,
        :only_process          => [],
        :path                  => ":rails_root/public:url",
        :preserve_files        => false,
        :processors            => [:thumbnail],
        :source_file_options   => {},
        :storage               => :media_lib,
        :styles                => {},
        :url                   => "/system/:class/:attachment/:id_partition/:style/:filename",
        :url_generator         => Paperclip::UrlGenerator,
        :use_default_time_zone => true,
        :use_timestamp         => true,
        :whiny                 => Paperclip.options[:whiny] || Paperclip.options[:whiny_thumbnails],
        :check_validity_before_processing => true
      }
    end

    # Путь необходим всегда, так что не смотрим на запись original_filename
    def path(style_name = default_style)
      path = interpolate(path_option, style_name)
      path.respond_to?(:unescape) ? path.unescape : path
    end

    # Всегда сохраняем старые файлы, убрали flush_deletes
    def save
      flush_writes
      @dirty = false
      true
    end
  end
end
