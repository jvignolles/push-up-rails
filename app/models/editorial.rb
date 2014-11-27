class Editorial < ActiveRecord::Base
  KINDS = {
    "homepage" =>       { menu: true,  url: "front_home_path" },
    "legal_info" =>     { menu: false, token: "legal-info" },
    #"contact" =>        { menu: true,  url: "new_front_contact_path" },
    #"privacy_policy" => { menu: false, token: "privacy-policy" },
    #"terms_of_use" =>   { menu: false, token: "terms-of-use" },
    "who_we_are" =>     { menu: false, token: "who-we-are" },
    "commitments" =>    { menu: false, token: "commitments" },
    "warranties" =>     { menu: false, token: "warranties" },
  }
  #IMAGE_KINDS = {
  #  :preview => "Bannière",
  #}.freeze
  #IMAGE_LEGENDABLE = true

  acts_as_clean_html :text1, :text2, :text3
  #acts_as_seo_keywords :seo_keywords
  reorderable
  slug :name
  strip_fields :name, :kind, :text1, :text2, :text3, :seo_title, :seo_h1, :seo_description, :seo_keywords

  #=== Validations
  validates :name, presence: true, maxlength_auto: true
  validates_presence_of :name
  validates :kind,
    maxlength_auto: true,
    uniqueness: {
      if: Proc.new { |e| e.kind.present? },
    }
  #validates_uniqueness_of :kind #, :if => lambda { |o| I18n.locale == I18n.default_locale && 'custom' != o.kind.to_s }

  #=== Triggers
  # …

  #=== Associations
  #has_many   :images, -> { order "position" }, as: :imageable, dependent: :destroy

  #=== Scopes
  scope :active,          -> { where(active: true) }
  scope :alphabetical,    -> { order("editorials.name, editorials.id") }
  scope :in_lateral_menu, -> { where(in_lateral_menu: true) }
  scope :adm_for_text, ->(opts) { 
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (editorials.id = ?"
      conditions << word.to_i
      ["name", "text1", "text2", "text3"].each do |field|
        conditions[0] << " or editorials.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }

  def self.has?(kind)
    ged = where(kind: kind).first
    ged.present? && strip_tags(ged.text).present?
  end

private
  def self.strip_tags(text)
    return "" if text.blank?
    text.gsub(%r(</?[^>]+>), "")
  end

  def validate
    errors.add(:kind, :invalid) if kind.present? && !KINDS.has_key?(kind.to_s)
  end
end
