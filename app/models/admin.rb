require "csv"
require "devise_backgrounder"

class Admin < ActiveRecord::Base
  include FormatMethods, CsvMethods
  extend FormatMethods, CsvMethods

  devise :database_authenticatable,
         #:confirmable,
         :recoverable,
         #:registerable,
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
  #before_validation :set_name_formats

  #=== Associations
  has_many :contacts
  has_many :quotations

  #=== Scopes
  scope :active,       -> { where(active: true) }
  scope :alphabetical, -> { order("admins.first_name, admins.last_name, admins.id") }
  scope :ordered,      -> { order("admins.created_at desc, admins.id desc") }
  scope :adm_for_text, ->(opts) { 
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (admins.id = ?"
      conditions += [word.to_i]
      ["first_name", "last_name", "email"].each do |field|
        conditions[0] << " or admins.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }

  #=== Methods
  def civil_name
    return full_name if civility.nil?
    "#{format_civility(civility)} #{full_name}"
  end

  def female?
    !male?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def formatted_phone(kind = :home)
    format_phone(send("phone_#{kind}"))
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

  def self.to_csv
    sql = %(
      SELECT a.id AS a_id, a.civility AS a_civility, a.first_name AS a_first_name, a.last_name AS a_last_name,
        a.email AS a_email, a.phone_home AS a_phone_home, a.phone_mobile AS a_phone_mobile, a.phone_work AS a_phone_work,
        a.created_at AS a_created_at
      FROM admins a
      ORDER BY a.created_at
    )
    utf8 = CSV.generate(csv_options) do |csv|
      csv << [
        "#ID", "Civilité", "Prénom", "Nom",
        "Email", "Tél. maison", "Tél. mobile", "Tél. travail",
        "Créé le",
      ]
      self.connection.select_all(sql).each do |x|
        csv << [
          x["a_id"], format_civility(x["a_civility"]), x["a_first_name"], x["a_last_name"],
          x["a_email"], x["a_phone_home"], x["a_phone_mobile"], x["a_phone_work"],
          format_datetime(x["a_created_at"], :export),
        ]
      end
    end
    utf8.encode(csv_ouput_encoding, invalid: :replace, undef: :replace, replace: "")
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
  end
end
