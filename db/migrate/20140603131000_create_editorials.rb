# encoding: utf-8
class CreateEditorials < ActiveRecord::Migration
  def change
    create_table :editorials, :force => true do |t|
      t.boolean  :active,                                       :default => true,       :null => false
      t.boolean  :in_lateral_menu,                              :default => true,       :null => false
      t.string   :name,                          :limit => 128, :default => '',         :null => false
      t.string   :kind,                          :limit => 128, :default => '',         :null => false
      t.text     :text1
      t.text     :text2
      t.text     :text3
      t.string   :seo_title,                     :limit => 128, :default => '',         :null => false
      t.string   :seo_h1,                        :limit => 128, :default => '',         :null => false
      t.string   :seo_description,               :limit => 255, :default => '',         :null => false
      t.text     :seo_keywords
      t.integer  :position,                                     :default => 0,          :null => false
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :editorials, :name
    add_index :editorials, :kind
    add_index :editorials, :position
    add_index :editorials, :created_at
  end
end

