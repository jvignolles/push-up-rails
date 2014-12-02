module Admin::ImagesHelper
  def allowed_image_extensions
    # JPG is just a tech variant of JPEG, also present.
    (ImageUploader.new.extension_white_list.map(&:upcase) - ['JPG']).to_sentence
  end

  def image_data(img)
    img.attributes.slice('id', 'legend', 'zoomable', 'kind')
  end

  def image_context(imageable)
    context = {}
    context[:copiable] ||= false
    context[:allows_many_images] ||= imageable.respond_to?(:images)
    context[:has_highlighted_image] ||= context[:allows_many_images] && imageable.respond_to?(:highlighted_image_id)
    context[:has_kinds] ||= imageable.class.const_defined?(:IMAGE_KINDS)
    context[:base_kinds] ||= imageable.class.const_get(:IMAGE_KINDS) if context[:has_kinds]
    context[:zoom_togglable] ||= imageable.class.const_defined?(:IMAGE_ZOOMABLE) && imageable.class.const_get(:IMAGE_ZOOMABLE)
    context[:zoom_enabled] ||= context[:zoom_togglable]
    context[:legendable] ||= imageable.class.const_defined?(:IMAGE_LEGENDABLE) && imageable.class.const_get(:IMAGE_LEGENDABLE)
    context[:hide_kinds] ||= imageable.class.const_defined?(:HIDE_IMAGE_KINDS)
    context[:has_attributes] ||= context[:zoom_enabled] || context[:legendable] || context[:has_kinds] && !context[:hide_kinds]
    @image ||= Image.new(imageable: imageable)
    context[:min_dims] = Image.dimensions_text(imageable, context[:has_kinds] && (@image.kind || context[:base_kinds].keys.first))
    context
  end
end
