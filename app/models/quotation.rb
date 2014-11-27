class Quotation < ActiveRecord::Base
  strip_fields :first_name, :last_name, :email, :phone, :description

  #=== Validations
  validates_presence_of :first_name, :last_name, :phone, :description
  validates :email, email: true, allow_blank: false
  #validate :validate

  #=== Triggers
  # …

  #=== Associations
  belongs_to :product

  #=== Scopes
  scope :ordered, -> { order("quotations.answered_at is null desc, quotations.created_at desc, quotations.id desc") }
  scope :waiting, -> { where(answered_at: nil) }
  scope :adm_for_text, ->(opts) { 
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (quotations.id = ?"
      conditions += [word.to_i]
      ["first_name", "last_name", "email", "phone", "description"].each do |field|
        conditions[0] << " or quotations.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }
  scope :since, ->(opts) {
    opts = opts.values if opts.is_a?(Hash)
    opts = [opts].flatten.reject(&:blank?)
    next where(nil) if opts.blank?
    where(["created_at >= ?", opts]).group("quotations.id")
  }
  scope :for_topic, ->(opts) {
    opts = opts.values if opts.is_a?(Hash)
    opts = [opts].flatten.reject(&:blank?)
    next where(nil) if opts.blank?
    where(["id = ? or parent_id = ?", opts, opts]).group("quotations.id")
  }

  #=== Methods
  def answer!(obj)
    if obj.is_a?(User) && (obj.admin || obj.super_admin)
      update_attributes! answered_at: Time.now, answerer_id: obj.id
    elsif obj.is_a?(Contact) && id != obj.id && id == obj.parent_id
      if obj.admin
        update_attributes! latest_answer_id: obj.id, answered_at: obj.created_at, answerer_id: obj.user_id
      else
        update_attributes! latest_answer_id: obj.id, answered_at: nil, answerer_id: nil
      end
    end
  end

  def answered?
    answered_at.present?
  end

  def from_url
    "http://#{Figaro.env.site_tld}#{from_path}"
  end

  def name
    [last_name, first_name].reject(&:blank?).join(" ")
  end

private
  def validate
    #if parent.blank?
    #  errors.add(:subject, :blank) if subject.blank?
    #end
    #if user.blank?
    #  errors.add(:name, :blank) if name.blank?
    #  errors.add(:email, :blank) if email.blank?
    #end
  end
end
