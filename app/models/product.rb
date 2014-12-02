class Product < ActiveRecord::Base
  IMAGE_KINDS = {
    :preview => "Mosaïque (vignette)",
    :panorama => "Mosaïque (panorama, un seul requis)",
  }
  IMAGE_LEGENDABLE = true

  acts_as_clean_html :resume, :description
  #acts_as_seo_keywords :seo_keywords
  reorderable
  slug :name
  strip_fields :name, :duration, :price, :resume, :description, :seo_title, :seo_h1, :seo_description, :seo_keywords

  #=== Validations
  validates :name, presence: true, maxlength_auto: true

  #=== Triggers
  # …

  #=== Associations
  has_many   :images, -> { order "position" }, as: :imageable, dependent: :destroy

  #=== Scopes
  scope :active,       -> { where(active: true) }
  scope :alphabetical, -> { order("products.name, products.id") }
  scope :highlighted,  -> { where(highlight: true) }
  scope :adm_for_text, ->(opts) {
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (products.id = ?"
      conditions << word.to_i
      ["name", "description"].each do |field|
        conditions[0] << " or products.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }

  #=== Methods
  # …
end
