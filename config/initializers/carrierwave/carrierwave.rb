# encoding: utf-8
# Be sure to restart your server when you modify this file.
CarrierWave::SanitizedFile.sanitize_regexp = /[^a-zA-Z0-9_\.\-]/

CarrierWave.configure do |config|
  if ENV["s3_enabled"].to_bool
    credentials = {}
    credentials[:provider] = "AWS"
    credentials[:aws_access_key_id] = ENV["aws_access_key_id"]                     # required
    credentials[:aws_secret_access_key] = ENV["aws_secret_access_key"]             # required
    if ENV["aws_region"].present?  # optional, defaults to "us-east-1"
      credentials[:region] = ENV["aws_region"]
      #credentials[:endpoint] = "https://#{ENV["aws_directory"]}.s3-#{ENV["aws_region"]}.amazonaws.com"
      #credentials[:endpoint] = "https://s3-#{ENV["aws_region"]}.amazonaws.com"
      #config.asset_host = "https://#{ENV["aws_directory"]}.s3-#{ENV["aws_region"]}.amazonaws.com" # optional, defaults to nil
    end
    config.fog_credentials = credentials
    config.fog_directory  = ENV["aws_directory"]                                   # required
    # config.fog_public     = false                                                         # optional, defaults to true
    config.fog_attributes = { "Cache-Control" => "max-age=315576000" }                    # optional, defaults to {}
    # config.storage = :fog # Already defined by CarrierWaveDirect
    config.use_action_status = true
  else
    config.permissions = 0666
    # config.directory_permissions = 0777
    config.storage = :file
  end
end

module CarrierWave
  module MiniMagick
    module ClassMethods
      def quality(percentage)
        process :quality => percentage
      end
      
      def strip
        process :strip
      end
    end
    
    # If we end up requiring processing of JPEG quality…
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage)
        img = yield(img) if block_given?
        img
      end
    end

    # Profile & comment stripping…
    def strip
      manipulate! do |img|
        img.strip
        img = yield(img) if block_given?
        img
      end
    end
  end

  # Force version variations at the *end* of names
  # (see https://github.com/jnicklas/carrierwave/wiki/How-To%3A-Move-version-name-to-end-of-filename%2C-instead-of-front)
  module Uploader::Versions
    def full_filename(for_file)
      parent_name = super(for_file)
      ext         = File.extname(parent_name).downcase
      base_name   = parent_name.downcase.chomp(ext) #.strip.gsub(/[\s_-]+/, '-')
      [base_name, version_name].compact.join('_') + ext
    end

    def full_original_filename
      parent_name = super
      ext         = File.extname(parent_name).downcase
      base_name   = parent_name.downcase.chomp(ext) #.strip.gsub(/[\s_-]+/, '-')
      [base_name, version_name].compact.join('_') + ext
    end
  end
end

