# encoding: utf-8
class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions, :force => true do |t|
      t.boolean  :active,                      :default => true,   :null => false
      t.string   :country_code, :limit => 2,   :default => "FR",   :null => false
      t.string   :name,         :limit => 50,  :default => "",     :null => false
      t.integer  :country_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :regions, :name
    add_index :regions, :created_at
  end
end

