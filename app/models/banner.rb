class Banner < ActiveRecord::Base
  IMAGE_KINDS = {
    :preview => "Bannière",
  }
  IMAGE_LEGENDABLE = true

  reorderable
  strip_fields :name, :url, :description

  #=== Validations
  validates :name, presence: true, maxlength_auto: true
  validates :url,  presence: true, maxlength_auto: true

  #=== Triggers
  # …

  #=== Associations
  has_many   :images, -> { order "position" }, as: :imageable, dependent: :destroy

  #=== Scopes
  scope :active,       -> { where(active: true) }
  scope :alphabetical, -> { order("banners.name, banners.id") }
  scope :adm_for_text, ->(opts) {
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (banners.id = ?"
      conditions += [word.to_i]
      ["name", "description"].each do |field|
        conditions[0] << " or banners.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }
end
