# encoding: utf-8

# The single image uploader for image management in the backoffice.  This is mirrored by a
# single controller (AdminImagesController) used in many nested routes, and a single
# model (Image).
#
# This uploader contains the entire set of possible image versions for all entities in the
# system, and defines the storage paths and names, processing (such as profile stripping),
# extension white list, etc.
#
# Most of its public code is there to deal with expected dimensions across numerous versions,
# many of them nested 2+ levels deep.
class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  if Figaro.env.s3_enabled.to_bool
    include CarrierWaveDirect::Uploader
  end

  # Custom storage paths.  We store all dynamic images (as in, images uploaded in the backoffice)
  # below the public directory's `dyn/images` subdir, scoping then by imageable (e.g. `products`,
  # `editorials`) and then cutting ID's in two 4-digit segments to ensure we don't exceed filesystem
  # child node capacity (often 64K).
  #
  # Example dir: `images/dynamic/products/0000/0042` (for Product #42's images)
  STORAGE_ROOT = "uploads/images"
  def store_dir
    if Figaro.env.s3_enabled.to_bool
      unless Rails.env.production?
        "#{Rails.env}/#{STORAGE_ROOT}/#{model.imageable_type.tableize}"
      else
        "#{STORAGE_ROOT}/#{model.imageable_type.tableize}"
      end
    else # local file system
      # TODO FIXME: id_segments = model.id.divmod(10_000).map { |i| '%04d' % i }.join('/')
      #"#{STORAGE_ROOT}/#{model.imageable_type.tableize}/#{id_segments}"
      "#{STORAGE_ROOT}/#{model.imageable_type.tableize}"
    end
  end
 
  def cache_dir
    # On Heroku, only /tmp is writable (care of concurrency!), so…
    Rails.root.join "tmp/uploads"
  end
 
  # Strip profiles and comments (custom command, see initializer)
  strip

  # Custom manipulations can be chained before thumbnail generation
  process :custom_manipulations

  # Generic versions
  version(:prefull) { process resize_to_limit: [674,400] }
  version(:medium, :from_version => :prefull) { process resize_to_limit: [nil, 135] }
  version(:small, :from_version => :prefull) { process resize_to_fill: [50, 50] }

  # Model-specific versions
  version :banner, :if => :banner? do
    version :preview, :if => :as_preview? do
      process resize_to_fill: [1920, 800]
      version(:lg) { process resize_to_fill: [1440, 600] }
      version(:md) { process resize_to_fill: [1020, 500] }
      version(:sm) { process resize_to_fill: [768, 500] }
      version(:xs) { process resize_to_fill: [480, 500] }
    end
  end

  version :configuration, :from_version => :prefull, :if => :configuration? do
    version :logo_app, :if => :as_logo_app? do
      process resize_to_limit: [nil, 104]
      version(:admin) { process resize_to_limit: [nil, 40] }
      version(:notifier) { process resize_to_limit: [nil, 35] }
    end
    #version :logo_app_white, :if => :as_logo_app_white? do
    #  process resize_to_limit: [nil, 104]
    #  version(:admin) { process resize_to_limit: [nil, 40] }
    #  version(:notifier) { process resize_to_limit: [nil, 35] }
    #end
    #version :logo_company, :if => :as_logo_company? do
    #  process resize_to_fill: [145, 46]
    #  #version(:retina) { process resize_to_fill: [290, 92] }
    #end
  end

  version :destination, :if => :destination? do
    version :preview, :if => :as_preview? do
      process resize_to_fill: [380, 260]
    end
  end

  version :editorial, :if => :editorial? do
    version :preview, :if => :as_preview? do
      process resize_to_limit: [nil, 600]
      version(:carrousel) { process resize_to_fill: [120, 80] }
      version(:mosaic_small) { process resize_to_fill: [210, 140] }
      version(:mosaic_large) { process resize_to_fill: [420, 280] }
    end
    version :banner, :if => :as_banner? do
      # TODO
      version(:lg) { process resize_to_fill: [1600, 600] }
      version(:md) { process resize_to_fill: [1200, 450] }
      version(:sm) { process resize_to_fill: [800, 480] }
      version(:xs) { process resize_to_fill: [500, 500] }
    end
  end

  version :highlight, :if => :highlight? do
    version :preview, :if => :as_preview? do
      process resize_to_fill: [380, 260]
    end
  end

  version :product, :if => :product? do
    version :preview, :if => :as_preview? do
      process resize_to_fill: [820, 560]
      version(:half) { process resize_to_fill: [410, 280] }
      version(:listing) { process resize_to_fill: [380, 260] }
    end
    version :panorama, :if => :as_panorama? do
      process resize_to_fill: [820, 280]
    end
    #version :banner, :if => :as_banner? do
    #  # TODO
    #  version(:lg) { process resize_to_fill: [1600, 600] }
    #  version(:md) { process resize_to_fill: [1200, 450] }
    #  version(:sm) { process resize_to_fill: [800, 480] }
    #  version(:xs) { process resize_to_fill: [500, 500] }
    #end
  end

  version :tag, :if => :tag? do
    version :preview, :if => :as_preview? do
      process resize_to_fill: [380, 260]
    end
  end

  # Returns the actual dimensions of a version's image file.  This means disk I/O as we're opening the file
  # and loading the image into MiniMagick.  `Image` provides a cache-aware version of this, so you should
  # never need to call this directly from outside code.
  #
  # Returns a `[width, height]` array.
  def actual_dimensions(version = nil)
    if :original == version || [:original] == version
      version = nil
    elsif :fullsize == version || [:fullsize] == version
      version = fullsize_version
    end
    current_version = version.present? ? get_version(*version) : self
    path = current_version.path
    image = {}
    image = MiniMagick::Image.open(path) if File.exists?(path)
    [image[:width], image[:height]]
  end

  # Fairly internal method, used only by `Image`, that provides a list of all the active (e.g. context-relevant)
  # version paths for this uploader's current image.
  def active_version_paths
    #paths = []
    paths = [[:original]]
    self.class.recurse_through_active_versions self do |n, _|
      paths << n
    end
    paths
  end

  # Returns the floating-point ratio of the fullsize dimensions for this image.
  # For instance, a 750x250 fullsize would yield a 3.0 ratio.  This is used by the cropper UI to force ratio.
  # If the ratio isn't fixed (see `fixed_ratio?` below), returns `'none'` (as this is intended for JS, which wouldn't
  # properly handle `nil` here).
  def aspect_ratio
    return 'none' unless fixed_ratio?
    dims = fullsize_settings[:dimensions]
    dims[0].to_f / dims[1]
  end

  def add_manipulation(method, *opts)
    @manipulation_list ||= []
    if method.present?
      @manipulation_list << { method: method, options: opts }
    end
    @manipulation_list
  end

  def custom_manipulations
    (@manipulation_list || []).each do |manipulation|
      send(manipulation[:method], *manipulation[:options])
    end
  end

  # Performs the actual image cropping, on the original image, assuming the passed coords are in prefull coordinate space.
  # Do NOT pass coordinates from any other coordinate space, as this will skew.  You should not call this method directly
  # as it is just one part of cropping; `Image` provides a wrapper method that takes care of preserving the original and prefull
  # while re-caching dimensions and maintaining version files.
  def crop!(x, y, w, h)
    prefull, orig = model.actual_dimensions(:prefull), model.actual_dimensions
    ratio = [orig[0].to_f / prefull[0], orig[1].to_f / prefull[1]].min
    x, y, w, h = [x, y, w, h].map { |n| (n * ratio).floor }
    manipulate! do |img|
      img.crop "#{w}x#{h}+#{x}+#{y}"
      img = yield(img) if block_given?
      img
    end
  end

  # Provides the fullsize dimensions text for a given imageable and, if necessary, a kind within that imageable.
  # This grabs fullsize settings as described in `fullsize_settings` and either returns a `width×height` text
  # (using an actual Unicode multiply sign), or provides a text specifying a minimum width or height, if only one
  # dimension was specified for the fullsize.
  def self.dimensions_text(imageable, kind = nil)
    image = Image.new(imageable: imageable, kind: kind)
    dims = fullsize_settings(image)[:dimensions]
    return dims.join('×') if dims.all?(&:present?)
    dims.first ? "#{dims.first} de large" : "#{dims.last} de haut"
  end

  # CarrierWave customization restricting the allowed image file extensions.  We currently only allow
  # JPEG (both usual exts), GIF and PNG.
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Tells whether both sizes (width and height) are known, or whether just one is defined.
  def fixed_ratio?
    fullsize_settings[:dimensions].all?(&:present?)
  end

  # Determines the fullsize settings (version path, processor and dimensions) for a given image.
  # This crawls through all active (context-relevant, so uses the image's imageable and kind, if any)
  # versions, recursively, and looks for the maximum-surface width+height version or, failing that,
  # the maximum-side width-or-height version.  The resulting hash has three keys:
  #
  # * `:version` is the version path (see `Image` doc).  This is used to convert the `:fullsize` shortcut
  #   to its actual path, for instance.
  # * `:processor` is the CarrierWave processor associated, such as `:resize_to_fit` or `:resize_to_fill`,
  #   for instance.
  # * `:dimensions` is a `[width, height]` array (one may be nil, if we only intend to constrain one dimension)
  #   for the version.  Usually, fullsize versions have both sides defined, though.
  def self.fullsize_settings(image, uploader = nil)
    uploader ||= new(image)
    settings = []
    recurse_through_active_versions uploader do |n, v|
      next if n.include?(:prefull)
      v.processors.each do |proc, dims, _|
        settings << { version: n, processor: proc, dimensions: dims }
      end
    end
    if settings.any? { |s| s[:dimensions].all?(&:present?) }
      settings.sort_by { |s| w, h = s[:dimensions].map(&:to_i); w * h }.last
    else
      settings.sort_by { |s| s[:dimensions].compact.first }.last
    end
  end

  # Convenience wrapper for the current uploader and its model around the class-level variant.
  # See there for details.
  def fullsize_settings
    self.class.fullsize_settings(model, self)
  end

  # Convenience wrapper picking the `:version` key (version path) from the `fullsize_settings`
  # resulting hash.
  def fullsize_version
    fullsize_settings[:version]
  end

  # Convenience accessor crawling through nested version accessors along a version path
  # to return the proper version object at the end of the path.  This is for internal use
  # inside `Image`, you should not need to call it directly.
  def get_version(*levels)
    levels.flatten!
    version = self
    version = version.send(levels.shift) while levels.present?
    version
  end

  # Performs the actual image padding, on the original image.
  # You should not call this method directly as it is just one part of padding; `Image` provides a
  # wrapper method that takes care of preserving the original and prefull while re-caching dimensions
  # and maintaining version files.
  def pad!(background = 'white')
    ratio = aspect_ratio
    w, h = actual_dimensions
    actual_ratio = w.to_f / h
    return false if ratio.round(4) == actual_ratio.round(4)
    new_w, new_h = ratio > actual_ratio ? [(ratio * h).floor, h] : [w, (w / ratio).floor]
    manipulate! do |img|
      img.resize_and_pad new_w, new_h, background
      img = yield(img) if block_given?
      img
    end
  end

private
  # Provides dynamic query methods for :if clauses of versions.  We care for two forms:
  #
  # * `blah?` checks the associated Image’s `imageable` class named, underscored.
  # * `as_blah?` checks the associated Image's `kind`.
  #
  # Any other call is forwarded to the inherited implementation (passthrough).
  def method_missing(name, *args, &block)
    if '?' == name[-1]
      if 'as_' == name[0, 3]
        name[3...-1] == model.kind.to_s
      else
        model.imageable.class.name.underscore == name[0...-1]
      end
    else
      super
    end
  end

  def self.recurse_through_active_versions(context, upper_levels = [], &block)
    context.send(:active_versions).each do |n, v|
      if v && v.send(:active_versions).present?
        recurse_through_active_versions v, upper_levels + [n], &block
      else
        block.call upper_levels + [n], v
      end
    end
  end
end

