class City < ActiveRecord::Base
  #=== Validations
  validates_presence_of :zip_code, :name
  validates_uniqueness_of :name, scope: :zip_code

  #=== Triggers
  # …

  #=== Associations
  belongs_to :state
  has_many   :addresses
  belongs_to :parent,   class_name: "City"
  has_many   :children, -> { order "id" }, class_name: "City", foreign_key: "parent_id"

  #=== Scopes
  scope :active,       -> { where(active: true) }
  scope :alphabetical, -> { order("cities.cedex, cities.name, cities.zip_code") }
  scope :adm_for_text, ->(opts) { 
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (cities.zip_code like ? or cities.name like ?)"
      conditions += ["#{word}%", "%#{word}%"]
    end
    where(conditions)
  }
  #scope :usual,         where(["cities.active = ? and cities.cedex = ? and cities.arrondissement = ?", true, false, ""])
  scope :with_companies,         -> { where("0 < cities.dnm_address_count") }
  scope :without_arrondissement, -> { where(arrondissement: "") }
  scope :without_cedex,          -> { where(cedex: false) }
  scope :without_fake_city,      -> { where(fake_city: false) }

  #=== Methods
  def full_name
    arrondissement.present? ? "#{name} #{arrondissement}" : name
  end
end
