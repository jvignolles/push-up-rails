class Country < ActiveRecord::Base
  include FormatMethods, CsvMethods
  extend FormatMethods, CsvMethods

  acts_as_clean_html :description
  #acts_as_seo_keywords :seo_keywords
  slug :name
  strip_fields :name, :description

  #=== Validations
  validates_presence_of   :name
  validates_uniqueness_of :name

  #=== Triggers
  # …

  #=== Associations
  # …

  #=== Scopes
  scope :active,       -> { where(active: true) }
  scope :alphabetical, -> { order("countries.name, countries.id") }
  scope :ordered,      -> { order("countries.name, countries.id") }
  scope :adm_for_text, ->(opts) {
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (countries.id = ?"
      conditions += [word.to_i]
      ["name", "description"].each do |field|
        conditions[0] << " or countries.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }
  scope :with_active_products, -> {
    joins = %(
      inner join countries_products cwap_cp on (countries.id = cwap_cp.country_id)
      inner join products cwap_p on (cwap_cp.product_id = cwap_p.id and cwap_p.active = 1)
    )
    joins(joins).group("countries.id")
  }
end
