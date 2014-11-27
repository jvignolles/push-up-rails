class Contact < ActiveRecord::Base
  strip_fields :name, :email, :phone, :subject, :description

  #=== Validations
  validates_presence_of :name, :description
  validates :email, email: true, allow_blank: false
  #validate :validate

  #=== Triggers
  # …

  #=== Associations
  belongs_to :admin
  has_many   :children, -> { order "created_at" }, class_name: "Contact", :foreign_key => "parent_id"
  belongs_to :parent,   class_name: "Contact"
  belongs_to :user

  #=== Scopes
  scope :ordered,       -> { order("contacts.answered_at is null desc, contacts.created_at desc, contacts.id desc") }
  #scope :user_ordered,  -> { order("contacts.created_at, contacts.id") }
  #scope :topics,        -> { where(parent_id: nil) }
  scope :waiting,       -> { where(parent_id: nil, answered_at: nil) }
  scope :adm_for_text, ->(opts) { 
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (contacts.id = ?"
      conditions += [word.to_i]
      ["name", "email", "subject", "description"].each do |field|
        conditions[0] << " or contacts.#{field} like ?"
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
    where(["created_at >= ?", opts]).group("contacts.id")
  }
  scope :for_topic, ->(opts) {
    opts = opts.values if opts.is_a?(Hash)
    opts = [opts].flatten.reject(&:blank?)
    next where(nil) if opts.blank?
    where(["id = ? or parent_id = ?", opts, opts]).group("contacts.id")
  }
  scope :for_user, ->(opts) {
    opts = opts.values if opts.is_a?(Hash)
    opts = [opts].flatten.reject(&:blank?)
    next where(nil) if opts.blank?
    where(user_id: opts).group("contacts.id")
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

  def full_name
    if user.present?
      user.full_name
    else
      name
    end
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
