# encoding: utf-8
class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities, :force => true do |t|
      t.boolean  :active,                      :default => true,   :null => false
      t.boolean  :cedex,                       :default => false,  :null => false
      t.string   :country_code, :limit => 2,   :default => "FR",   :null => false
      t.integer  :state_id
      t.string   :zip_code,     :limit => 16,  :default => "",     :null => false
      t.string   :name,         :limit => 50,  :default => "",     :null => false
      t.decimal  :lat,          :precision => 15, :scale => 10
      t.decimal  :lng,          :precision => 15, :scale => 10
      t.boolean  :fake_city,                                                       :default => false, :null => false
      t.string   :arrondissement,    :limit => 3,                                  :default => "",    :null => false
      t.integer  :parent_id
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :cities, :state_id
    add_index :cities, [:zip_code, :name]
    add_index :cities, :created_at
  end
end

