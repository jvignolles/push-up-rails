# encoding: utf-8
class CreateConfigurations < ActiveRecord::Migration
  def self.up
    self.transaction do
      create_table :configurations, :force => true do |t|
        t.string   :app_name,                      :limit => 128, :default => '',         :null => false
        t.string   :baseline,                                     :default => '',         :null => false
        t.string   :email_contact,                 :limit => 128, :default => '',         :null => false
        t.string   :company_name,                  :limit => 128, :default => '',         :null => false
        t.string   :phone,                         :limit => 20,  :default => '',         :null => false
        t.string   :phone_hours,                   :limit => 128, :default => '',         :null => false
        t.string   :fax,                           :limit => 20,  :default => '',         :null => false
        t.string   :address,                                      :default => '',         :null => false
        t.string   :siret,                         :limit => 14,  :default => '',         :null => false
        t.string   :siren,                         :limit => 9,   :default => '',         :null => false
        t.string   :intracom_vat_number,           :limit => 32,  :default => '',         :null => false
        t.text     :quotation_description
        t.text     :newsletter_description
        t.string   :seo_title,                     :limit => 128, :default => '',         :null => false
        t.string   :seo_description,               :limit => 255, :default => '',         :null => false
        t.text     :seo_keywords
        t.boolean  :website_on_hold,                              :default => false,      :null => false
        t.text     :website_on_hold_description
        # Social networks
        t.string   :facebook_url,                  :limit => 128, :default => '',         :null => false
        t.string   :twitter_url,                   :limit => 128, :default => '',         :null => false
        t.string   :googleplus_url,                :limit => 128, :default => '',         :null => false
        t.string   :instagram_url,                 :limit => 128, :default => '',         :null => false
        t.string   :pinterest_url,                 :limit => 128, :default => '',         :null => false
        t.string   :linkedin_url,                  :limit => 128, :default => '',         :null => false
        t.string   :viadeo_url,                    :limit => 128, :default => '',         :null => false
        # Rails dates
        t.datetime :created_at
        t.datetime :updated_at
      end
    end
  end

  def self.down
    self.transaction do
      drop_table :configurations
    end
  end
end

