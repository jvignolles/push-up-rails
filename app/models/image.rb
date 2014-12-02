require 'fileutils'
require 'tempfile'

# The core class for image management in the backoffice.  This is mirrored by a
# single controller (Admin::ImagesController) used in many nested routes, and a single
# uploader (ImageUploader) for CarrierWave functionality.
#
# Images can be bound in a 1-1 or 1-n fashion to any imageable using a polymorphic
# relation like `has_one :image, as: :imageable` or `has_many :images, as: :imageable`.
# Don't forget to make these `dependent: :destroy`, as it is usually desired.
#
# ## Version paths
#
# With CarrierWave and nested version definitions, we don't have a single, flat list of
# thumbnails/versions anymore, we have a sequence of version scopes.  This means we don't
# have an actual `:fullsize` anymore, but version paths for it that vary based on context.
#
# Look at the versions defined in `ImageUploader`; for instance, a logo-kind brand image
# would find its fullsize (largest surface) at path `[:brand, :logo, :large]`, but its
# generic versions remain at the root level (e.g. `:medium` and `:small_thumb`). On the
# other hand, a product's fullsize version would be at `[:product, :zoomed]`.
#
# All methods taking a version/thumb (parameters named `thumb` usually) accept
# a version path, either as individual arguments or as an array argument.  They also
# allow the traditional `:fullsize` value as a shortcut, which will get converted to
# the proper version path as per `ImageUploader#fullsize_version`.
class Image < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  unless defined?(@@__copying)
    @@__copying = false # HACK
  end

  belongs_to :imageable, :polymorphic => true, :touch => true

  #attr_accessible :imageable, :img
  attr_accessor :manipulations

  mount_uploader :img, ImageUploader

  after_initialize :initializations
  before_save :cache_dimensions
  before_create :set_content_type, :set_position
  after_update :check_kind_change

  def initializations
    @manipulations ||= []
  end

  # Assisted images were interactively cropped or surrounded.
  scope :assisted, -> { where(assisted: true) }

  # Some images are single-locale; this scope only uses locale-agnostic and passed-locale-specific
  # images, ignoring those specific to another locale.  If no locale is passed, the current locale
  # is used.
  scope :for_locale, ->(*loc) {
    loc = loc.first.to_s.downcase
    loc = I18n.locale if 'current' == loc || !loc[/^[a-z]{2}$/]
    where('images.single_locale IS NULL OR images.single_locale = ?', loc)
  }

  # Several imageables use various kinds of images, each kind having its own set of versions.
  # It is declared through an `IMAGE_KINDS` constant at the imageable's class level.  This lets
  # us filter on kind.
  scope :for_kind, ->(k) { where(kind: k) }

  scope :latest_user_profiles, ->(*opts) {
    opts = {} if opts.blank?
    opts = { limit: opts.first.to_i } if opts.is_a?(Array) && opts.first.present?
    opts[:limit] ||= 30
    where(imageable_type: "User", kind: "profile").order("images.created_at desc").limit(opts[:limit])
  }

  serialize :dimensions, Hash

  # Retrieves the actual dimensions of a given version (version path, see class doc).  By default,
  # this will use the cached dimensions for it, if any (serialized in the `dimensions` hash), but you
  # can force file-based extraction by specifying a `force: true` option after the version path.
  # This returns a `[width, height]` array or `nil` if the version path is unusable.
  #
  # Examples:
  #
  #     image.actual_dimensions :brand, :logo, :large
  #     image.actual_dimensions :medium, force: true
  #     image.actual_dimensions [:brand, :logo]
  def actual_dimensions(*thumb)
    options = thumb.extract_options!.symbolize_keys
    thumb = thumb.flatten.reject(&:blank?).map(&:to_sym)
    if thumb.blank?
      thumb = [:original]
    elsif [:fullsize] == thumb
      thumb = img.fullsize_version
    end
    if options[:force] || (dimensions || {})[thumb].blank?
      img.actual_dimensions(thumb)
    else
      dims = dimensions[thumb]
      dims = img.actual_dimensions(thumb) if [nil, nil] == dims
      dims
    end
  end

  # Useful little method intended for chronic (typically scheduled Rake task) use that
  # removes obsolete storage paths (when an `Image` is removed, its files get deleted but the
  # containing directories are left alone, which can lead to many empty directories over time).
  def self.cleanup_empty_storage
    unless Figaro.env.s3_enabled.to_bool
      path = File.join(Rails.root, 'public', ImageUploader::STORAGE_ROOT)
      Rails.logger.info "[#{Time.zone.now} Storage Cleanup] Cleaning up empty dynamic image directories…"
      %x(find #{Shellwords.escape path} -mindepth 1 -type d -empty -delete)
      Rails.logger.info "[#{Time.zone.now} Storage Cleanup] Storage cleaned."
    end
  end

  # Copies the current image, along with all its versions, to a new image.  This uses
  # raw SQL and file copies to speed up processing, except for the ID and position,
  # which are updated (copy appears right after the copied image).
  def copy!
    attrs = attributes.symbolize_keys.except(:id, :img)
    attrs[:position] += 1

    self.class.transaction do
      @@__copying = true
      cnx = self.class.connection
      cnx.execute %(
        UPDATE #{self.class.quoted_table_name}
        SET position = position + 1
        WHERE position >= #{cnx.quote attrs[:position]} AND imageable_type = #{cnx.quote self.class.name} AND imageable_id = #{cnx.quote id}
      )
      new_image  = self.class.create!(attrs)
      src_dir    = File.dirname(img.path)
      target_dir = File.join(Rails.root, 'public', new_image.img.store_dir)
      # Ensure the parent directory exists
      FileUtils.makedirs File.dirname(target_dir)
      # Ensure the directory doesn't exist, so we don't copy src_dir itself inside it
      FileUtils.rm_rf target_dir
      # Copy!
      FileUtils.cp_r src_dir, target_dir
      # Restore CarrierWave image binding
      new_image.send(:write_attribute, :img, File.basename(img.path))
      new_image.save!
      @@__copying = false
    end
  end

  # Crops the image using the given coordinates, expected in the prefull-image coordinate space
  # (NOT the fullsize space).  Coordinates are auto-adjusted using the prefull-to-original ratio.
  #
  # This restores the original image and the prefull image to their original files post-crop, so
  # later crops can be performed from the same original basis.  Versions are generated anew and
  # dimensions are re-cached.
  #
  # In case it's unclear, the four expected arguments are left, top, width and height of the crop
  # area, in pixels (again, on the prefull image coordinate space).
  def crop(x, y, w, h)
    @manipulations << { method: :crop!, options: [x, y, w, h] }
  end

  def crop!(x, y, w, h)
    crop x, y, w, h
    save_and_process!
  end

  # Returns a textual description of the fullsize dimensions expected for a given imageable, with an
  # specific kind within that imageable, if applicable.  See `ImageUploader.dimensions_text` for
  # further details, as this delegates to it.
  def self.dimensions_text(imageable, kind = nil)
    ImageUploader.dimensions_text(imageable, kind)
  end

  # Returns the actual dimensions of a given version (version path, see class doc) for this image, assuming
  # versions were created already (which is a fairly safe bet!).  This uses cached dimensions, if available.
  # The result String is of the `width×height` form (using a proper Unicode multiply sign).
  def dimensions_text(*thumb)
    img.actual_dimensions(*thumb).join('×')
  end

  def assist_min_crop_dimensions
    w1, h1 = min_crop_dimensions
    w2, h2 = actual_dimensions
    return [w1, h1] if !w1 || !h1 || !w2 || !h2 || (w1 <= w2 && h1 <= h2) # Image large enough
    if w1 * h2 > w2 * h1
      return [w2, (w2.to_f / w1 * h1).round]
    else
      return [(h2.to_f / h1 * w1).round, h2]
    end
  end

  # Computes the minimum cropping dimensions required for the uploader's current image,
  # based on its prefull, original and fullsize dimension sets.  This is used by the cropper UI.
  #
  # Returns a `[width, height]` array.
  def min_crop_dimensions
    prefull  = actual_dimensions(:prefull)
    orig     = actual_dimensions
    fullsize = img.fullsize_settings[:dimensions]
    [0, 1].map { |i| 0 < orig[i].to_i ? (prefull[i].to_f / orig[i].to_i * fullsize[i].to_i).ceil : 0 }
  end

  # Legacy helper so most of the app code doesn't need to be rewritten in (admittedly more verbose sometimes)
  # CarrierWave uploader parlance.  The version is passed as a version path (see class docs).
  # This returns the public URL (domain-relative) for the versioned image.
  #
  # Warning: if no version path is passed, we're using the *original* (possibly very big) image, so be sure to
  # always specify `:fullsize` when that's what you want.
  def full_filename(*thumb)
    thumb = img.fullsize_version if [:fullsize] == thumb
    img.get_version(*thumb).path
  end

  def assisted!(assisted = true)
    if !new_record? && self.assisted != assisted
      update_column :assisted, assisted
    end
    self.assisted = assisted
  end

  # Pads the image with a given color so it gets the proper aspect ratio, then recomputes versions.
  #
  # This restores the original image and the prefull image to their original files post-crop, so
  # later crops can be performed from the same original basis.  Versions are generated anew and
  # dimensions are re-cached.
  #
  # The background defaults to white, but we can pad with any color. The color can be anything
  # [ImageMagick understands](http://www.imagemagick.org/script/color.php) (which includes
  # :transparent, by the way).
  def pad(background = 'white')
    @manipulations << { method: :pad!, options: background }
  end

  def pad!(background = 'white')
    pad background
    save_and_process!
  end

  # Legacy helper so most of the app code doesn't need to be rewritten in (admittedly more verbose sometimes)
  # CarrierWave uploader parlance.  The version is passed as a version path (see class docs).
  # This returns the public URL (domain-relative) for the versioned image.
  #
  # Warning: if no version path is passed, we're using the *original* (possibly very big) image, so be sure to
  # always specify `:fullsize` when that's what you want.
  def public_filename(*thumb)
    thumb = img.fullsize_version if [:fullsize] == thumb
    img.get_version(*thumb).url
  end

  def destroy_and_process!(opts = {})
    if !Figaro.env.worker_enabled.to_bool || opts[:now]
      self.destroy
    else
      ImageWorker.perform_async(id, "destroy")
    end
  end

  def save_and_process!(opts = {})
    opts ||= {}
    opts.symbolize_keys!
    # Process file if called from worker or if worker is disabled, otherwise save and queue job
    if !Figaro.env.worker_enabled.to_bool || opts[:now]
      wrapped_image_tweak do
        @manipulations.each do |manipulation|
          manipulation.symbolize_keys!
          img.add_manipulation(manipulation[:method], *manipulation[:options])
        end
      end
    else
      if save
        # Queue for background processing
        ImageWorker.perform_async(id, "manipulations", manipulations: @manipulations)
      else
        return false
      end
    end
  end

  # Tells whether the original image is smaller than the fullsize image.
  def too_small?
    w, h = actual_dimensions
    fsw, fsh = img.fullsize_settings[:dimensions]
    w && h && fsw && fsh && (fsw > w || fsh > h)
  end

private
  def cache_dimensions
    return true if new_record? ? dimensions.present? : assisted? # copy! use case
    self.dimensions = {}
    img.active_version_paths.each do |v|
      self.dimensions[v] = actual_dimensions(*v, force: true)
    end
    true
  end

  def check_kind_change
    if kind_changed? && !@single_pass
      @single_pass = true
      img.send :remove_versions!
      img.recreate_versions!
      cache_dimensions
      save!
    end
    true
  end

  def set_content_type
    unless @@__copying
      self.content_type = img.path.present? && ::MIME::Types.type_for(img.path).first.to_s
    end
  end

  def set_position
    self.position ||= if imageable_id
      (self.class.where(imageable_type: imageable_type, imageable_id: imageable_id).maximum(:position) || 0) + 1
    else
      0
    end
  end

  def wrapped_image_tweak(&block)
    if Figaro.env.s3_enabled.to_bool
      # Define image manipulations (do it first to avoid many thumbnail re-generations)
      block.call if block_given?
      current_img_url = img.direct_fog_url(with_path: true)
      # Download the fullsized image from S3, process it and generate all the thumbnails
      self.remote_img_url = current_img_url
      # Upload thumbnails to S3
      save!
      assisted!
    else
      backup = File.join(Dir::tmpdir, File.basename(img.current_path))
      FileUtils.copy img.current_path, backup
      begin
        block.call if block_given?
        # The save inside triggers proper cache expiries so recreate_versions! works from the proper source
        # (this took me 3+ hours to find out…)
        assisted!
        img.recreate_versions!
      ensure
        # Restore fullsize
        FileUtils.copy backup, img.current_path
      end
      # Derive prefull from restored fullsize, leave other versions alone.
      img.prefull.process!
      img.prefull.store! img
      # Update cached dimensions
      #cache_dimensions
      save!
    end
    # Done!
    self
  end
end
