module Paperclip
  module Storage
    module MediaLib
      def self.extended base
      end

      def exists?(style = default_style)
        true
      end

      def flush_writes #:nodoc:
        for style, file in @queued_for_write do
          log("saving #{path(style)}")
          begin
            uri = URI.parse(@options[:request_url])

            boundary = "AaB03x"

            data = File.read(file.path)
            prefix = path.gsub(original_filename, '')
            sign = Digest::MD5.hexdigest(prefix + @options[:secret_key])

            post_body = []
            post_body << "--#{boundary}\r\n"
            post_body << "Content-Disposition: form-data; name=files; filename=#{original_filename}\r\n"
            post_body << "Content-Type: #{file.content_type}\r\n"
            post_body << "\r\n"
            post_body << data
            post_body << "\r\n--#{boundary}--\r\n"

            http = Net::HTTP.new(uri.host, uri.port)
            request = Net::HTTP::Post.new(uri.request_uri + "?sign=#{sign}&prefix=#{prefix}")
            request.body = post_body.join
            request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"

            http.request(request)
          rescue
            raise
          ensure
            file.rewind
          end
        end
      end

      def flush_deletes
        if @options[:request_url]
          begin
            delete path
          rescue
            true
          end

          for path in @queued_for_delete do
            delete path
          end
        end
        @queued_for_delete = []
      end

      def copy_to_local_file(style, local_dest_path)
        true
      end

      private
        def delete path
          if path.split('/').first == 'gallery_files'
            true
          elsif path.split('/').first == 'galleries'
            sign = Digest::MD5.hexdigest(g_path + @options[:secret_key])
            log("deleting #{path}")
            uri = URI.parse(@options[:request_url] + '/' + path)
            http = Net::HTTP.new(uri.host, uri.port)
            request = Net::HTTP::Delete.new(uri.request_uri + "?sign=#{sign}")
            http.request(request)

            g_path = path.gsub('galleries', 'gallery_files')
            log("deleting #{g_path}")
            uri = URI.parse(@options[:request_url] + '/' + g_path)
            http = Net::HTTP.new(uri.host, uri.port)
            request = Net::HTTP::Delete.new(uri.request_uri + "?sign=#{sign}")
            http.request(request)
          else
            sign = Digest::MD5.hexdigest(path + @options[:secret_key])
            log("deleting #{path}")
            uri = URI.parse(@options[:request_url] + '/' + path)
            http = Net::HTTP.new(uri.host, uri.port)
            request = Net::HTTP::Delete.new(uri.request_uri + "?sign=#{sign}")

            http.request(request)
          end
        end
    end
  end
end
