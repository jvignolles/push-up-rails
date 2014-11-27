# encoding: utf-8
class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products, :force => true do |t|
      t.boolean  :active,                                       :default => true,       :null => false
      t.string   :name,                          :limit => 128, :default => '',         :null => false
      t.string   :price,                         :limit => 32,  :default => '',         :null => false
      t.text     :resume
      t.text     :preview
      t.text     :description
      t.string   :seo_title,                     :limit => 128, :default => '',         :null => false
      t.string   :seo_h1,                        :limit => 128, :default => '',         :null => false
      t.string   :seo_description,               :limit => 255, :default => '',         :null => false
      t.text     :seo_keywords
      t.integer  :position,                                     :default => 0,          :null => false
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :products, :name
    add_index :products, :position
    add_index :products, :created_at
  end
end

