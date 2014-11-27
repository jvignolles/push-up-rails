module CarrierWave
  module Storage
    class Fog < Abstract
      class File
        def public_url
          encoded_path = encode_path(path)
          if host = @uploader.asset_host
            if host.respond_to? :call
              "#{host.call(self)}/#{encoded_path}"
            else
              "#{host}/#{encoded_path}"
            end
          else
            # AWS/Google optimized for speed over correctness
            case @uploader.fog_credentials[:provider]
            when 'AWS'
              # check if some endpoint is set in fog_credentials
              if @uploader.fog_credentials.has_key?(:endpoint)
                "#{@uploader.fog_credentials[:endpoint]}/#{@uploader.fog_directory}/#{encoded_path}"
              else
                protocol = @uploader.fog_use_ssl_for_aws ? "https" : "http"
                # if directory is a valid subdomain, use that style for access
                if @uploader.fog_directory.to_s =~ /^(?:[a-z]|\d(?!\d{0,2}(?:\d{1,3}){3}$))(?:[a-z0-9\.]|(?![\-])|\-(?![\.])){1,61}[a-z0-9]$/
                  # DEV NOTE: FIXED URL
                  "#{protocol}://#{@uploader.fog_directory}.s3-#{@uploader.fog_credentials[:region]}.amazonaws.com/#{encoded_path}"
                else
                  # directory is not a valid subdomain, so use path style for access
                  # DEV NOTE: FIXED URL
                  "#{protocol}://s3-#{@uploader.fog_credentials[:region]}.amazonaws.com/#{@uploader.fog_directory}/#{encoded_path}"
                end
              end
            when 'Google'
              "https://commondatastorage.googleapis.com/#{@uploader.fog_directory}/#{encoded_path}"
            else
              # avoid a get by just using local reference
              directory.files.new(:key => path).public_url
            end
          end
        end

      end
    end
  end
end

