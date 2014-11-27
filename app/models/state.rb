class State < ActiveRecord::Base
  strip_fields :name, :code

  #=== Validations
  validates_presence_of   :name, :code
  validates_uniqueness_of :name, scope: :country_code
  validates_uniqueness_of :code, scope: :country_code

  #=== Triggers
  # …

  #=== Associations
  belongs_to :region
  has_many   :cities

  #=== Scopes
  scope :active,       -> { where(active: true) }
  scope :alphabetical, -> { order("states.name, states.id") }
  scope :adm_for_text, ->(opts) { 
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (states.id = ?"
      conditions += [word.to_i]
      ["name", "code"].each do |field|
        conditions[0] << " or states.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }
end
