# encoding: utf-8
class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners, :force => true do |t|
      t.boolean  :active,                      :default => true,   :null => false
      t.string   :name,         :limit => 50,  :default => "",     :null => false
      t.string   :url,                           :limit => 128, :default => '',         :null => false
      t.string   :description,  :limit => 255, :default => "",     :null => false
      t.string   :button,       :limit => 50,  :default => "",     :null => false
      t.integer  :position,                    :default => 0,      :null => false
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :banners, :name
    add_index :banners, :position
    add_index :banners, :created_at
  end
end

