require 'csv'
require 'devise_backgrounder'

class User < ActiveRecord::Base
  include FormatMethods, CsvMethods
  extend FormatMethods, CsvMethods

  IMAGE_KINDS = {
    :profile => "Profil",
  }.freeze

  devise :database_authenticatable,
         :confirmable,
         :recoverable,
         :registerable,
         :rememberable,
         :trackable,
         #:timeoutable,
         #:validatable,
         :lockable,
         :sidekiq,
         :email_info

  strip_fields :first_name, :last_name, :phone_home, :phone_mobile, :phone_work, :email

  #=== Validations
  validates :first_name, :last_name, presence: true, maxlength_auto: true
  validates :email,
    maxlength_auto: true,
    uniqueness: {
      if: Proc.new { |u| u.email.present? },
    },
    #presence: { if: Proc.new { |u| u.confirmed? } },
    email: { if: Proc.new { |u| u.email.present? } }
  validates :password,
    presence: { if: Proc.new { |u| u.password.present? } },
    length: { in: 4..32, if: Proc.new { |u| u.password.present? } }
  validate :validate

  #=== Triggers
  before_validation :set_name_formats

  #=== Associations
  has_one    :address, dependent: :destroy
  has_many   :contacts, dependent: :destroy
  has_many   :images, -> { order "position" }, as: :imageable, dependent: :destroy
  has_many   :subscriptions, dependent: :destroy
  accepts_nested_attributes_for :address, allow_destroy: true #:reject_if => lambda { |a| a[:content].blank? }

  #=== Scopes
  scope :active,       -> { where(active: true) }
  scope :alphabetical, -> { order("users.first_name, users.last_name, users.id") }
  scope :ordered,      -> { order("users.created_at desc, users.id desc") }
  scope :adm_for_text, ->(opts) {
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (users.id = ?"
      conditions << word.to_i
      ["first_name", "last_name", "email"].each do |field|
        conditions[0] << " or users.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }
  scope :latest_subscriptions, ->(*opts) {
    limit = 10
    order("users.created_at desc").limit(limit)
  }

  #=== Methods
  def civil_name
    return full_name if civility.nil?
    "#{format_civility(civility)} #{full_name}"
  end

  def female?
    !male?
  end

  def formatted_phone(kind = :home)
    format_phone(send("phone_#{kind}"))
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def male?
    "mr" == civility
  end

  def name
    civil_name
  end
  
  def short_name
    "#{first_name} #{last_name.first}."
  end

private
  def set_name_formats
    self.first_name.to_s.nameize!
    self.last_name.to_s.nameize!
    true
  end

  def validate
    if !password_confirmation.nil? && password_confirmation != password
      errors.add(:password_confirmation, I18n.t("errors.messages.confirmation"))
    end
    errors.add(:terms_of_use, :accepted) unless terms_of_use
  end
end
