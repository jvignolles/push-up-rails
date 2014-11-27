class Configuration < ActiveRecord::Base
  IMAGE_KINDS = {
    :logo_app => "Logo",
    #:logo_app_white => "Logo (blanc)",
  }.freeze

  strip_fields :app_name, :baseline, :email_contact, :company_name, :phone, :phone_hours, :fax, :address, :siret, :siren, :intracom_vat_number, :quotation_description, :newsletter_description, :seo_title, :seo_description, :seo_keywords, :website_on_hold_description, :facebook_url, :twitter_url, :googleplus_url, :instagram_url, :pinterest_url, :linkedin_url, :viadeo_url

  #=== Validations
  validates_presence_of :app_name, :email_contact, :company_name

  #=== Triggers
  # …

  #=== Associations
  has_many   :images, -> { order "position" }, as: :imageable, dependent: :destroy

  #=== Scopes
  # …

  #=== Methods
  def self.instance
    Configuration.first rescue nil
  end

  private :destroy
  private_class_method :new, :create
end
