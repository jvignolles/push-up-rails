class Region < ActiveRecord::Base
  strip_fields :name

  #=== Validations
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :country_code

  #=== Triggers
  # …

  #=== Associations
  has_many :states

  #=== Scopes
  scope :active,       -> { where(active: true) }
  scope :alphabetical, -> { order("regions.name, regions.id") }
  scope :adm_for_text, ->(opts) { 
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (regions.id = ?"
      conditions += [word.to_i]
      ["name"].each do |field|
        conditions[0] << " or regions.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }
end
