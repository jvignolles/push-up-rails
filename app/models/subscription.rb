require 'csv'

class Subscription < ActiveRecord::Base
  include FormatMethods, CsvMethods
  extend FormatMethods, CsvMethods

  strip_fields :email

  #=== Validations
  validates_presence_of :email, :kind
  validates_uniqueness_of :email, scope: :kind

  #=== Triggers
  # …

  #=== Associations
  belongs_to :user

  #=== Scopes
  scope :active,       -> { where(active: true) }
  scope :alphabetical, -> { order("subscriptions.email, subscriptions.id") }
  scope :for_kind,     ->(k) { where(kind: k) }
  scope :ordered,      -> { order("subscriptions.created_at desc, subscriptions.id desc") }
  scope :adm_for_text, ->(opts) {
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    words.each do |word|
      conditions[0] << " and (subscriptions.id = ?"
      conditions += [word.to_i]
      ["email"].each do |field|
        conditions[0] << " or subscriptions.#{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] << ")"
    end
    where(conditions)
  }

  #=== Methods
  def name
    email
  end

  def self.to_csv
    sql = %(
      SELECT s.id AS s_id, s.email AS s_email, s.created_at AS s_created_at
      FROM subscriptions s
      ORDER BY s.created_at DESC
    )
    utf8 = CSV.generate(csv_options) do |csv|
      csv << [
        "#ID", "Email", "Créé le",
      ]
      self.connection.select_all(sql).each do |x|
        csv << [
          x["s_id"], x["s_email"], format_datetime(x["s_created_at"], :export),
        ]
      end
    end
    utf8.encode(csv_ouput_encoding, invalid: :replace, undef: :replace, replace: "")
  end
end
