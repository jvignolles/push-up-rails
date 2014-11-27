module CarrierWave
  module Storage
    class Fog < Abstract
      class File

        # HACK: to keep the original fullsized image, we simply don't re-upload it.
        # In this way, it can be easily manipulated to generate all the thumbnails.
        #
        # The "prefull" thumbnail follow the same behaviour (remember: it's the browser
        # preview to save bandwidth). Only one exception: this thumbnail require to be
        # generated and uploaded the very first time (ie. when the model is not
        # "assisted?").
        # 
        def store_with_checks(new_file)
          if @uploader.version_name.present? && (!@uploader.model.assisted? || "prefull" != @uploader.version_name.to_s)
            store_without_checks(new_file)
          else
            true
          end
        end

        alias_method_chain :store, :checks

      end
    end
  end
end

