class TeamMember < ActiveRecord::Base
  include FormatMethods
  extend FormatMethods

  IMAGE_KINDS = {
    :profile => "Profil",
  }.freeze

  acts_as_clean_html :description
  reorderable
  strip_fields :first_name, :last_name, :description

  #=== Validations
  validates :first_name, :last_name, presence: true, maxlength_auto: true
  validates :description, presence: true

  #=== Triggers
  # …

  #=== Associations
  has_many   :images, -> { order "position" }, as: :imageable, dependent: :destroy

  #=== Scopes
  scope :active,       -> { where(active: true) }
  scope :alphabetical, -> { order("team_members.name, team_members.id") }
  scope :adm_for_text, ->(opts) {
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (team_members.id = ?"
      conditions << word.to_i
      ["name", "description"].each do |field|
        conditions[0] << " or team_members.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }
  scope :with_profile, ->(*opts) {
    opts = {} if opts.blank?
    opts = { limit: opts.first.to_i } if opts.is_a?(Array) && opts.first.present?
    opts[:limit] ||= 10
    joins = %(INNER JOIN images tmp_i ON (tmp_i.imageable_id = team_members.id AND tmp_i.imageable_type = 'TeamMember' AND tmp_i.kind = 'profile'))
    joins(joins).limit(opts[:limit]).group("team_members.id")
  }

  #=== Methods
  def civil_name
    return full_name if civility.nil?
    "#{format_civility(civility)} #{full_name}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def name
    civil_name
  end

  def short_name
    "#{first_name} #{last_name.first}."
  end
end
