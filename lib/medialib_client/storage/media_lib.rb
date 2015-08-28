module Paperclip
  module Storage
    module MediaLib
      def self.extended base
      end

      def exists?(style = default_style)
        true
      end

      def flush_writes #:nodoc:
        processors = @options[:processors]

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

            if processors.is_a?(Array)
              opt = processors.map{|p| "#{p}=true"}.join('&')
              opt = '&' + opt if opt != ''
            end

            request = Net::HTTP::Post.new(uri.request_uri + "?sign=#{sign}&prefix=#{prefix}#{opt}")
            request.body = post_body.join
            request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"

            send_request(uri, request)
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
          true
        end

        def send_request(uri, request)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.scheme == 'https'
          response = http.request(request)

          if response && response.code =~ /30\d/ && response.to_hash['location']
            uri = URI.parse(response.to_hash['location'][0])
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true if uri.scheme == 'https'
            http.request(request)
          end
        end
    end
  end
end
