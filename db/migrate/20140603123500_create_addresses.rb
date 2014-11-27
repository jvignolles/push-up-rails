# encoding: utf-8
class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses, :force => true do |t|
      t.string   :old_id,       :limit => 36,  :default => "",     :null => false
      t.string   :address,      :limit => 64,  :default => "",     :null => false
      t.string   :complement,   :limit => 64,  :default => "",     :null => false
      t.string   :zip_code,     :limit => 16,  :default => "",     :null => false
      t.string   :city_name,    :limit => 64,  :default => "",     :null => false
      t.integer  :city_id
      t.string   :state_name,   :limit => 64,  :default => "",     :null => false
      t.string   :country_name, :limit => 48,  :default => "",     :null => false
      t.string   :country_code, :limit => 2,   :default => :FR,    :null => false
      #t.decimal  :lat,          :precision => 15, :scale => 10
      #t.decimal  :lng,          :precision => 15, :scale => 10
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :addresses, :old_id
    add_index :addresses, :zip_code
    add_index :addresses, :city_name
    add_index :addresses, :city_id
    add_index :addresses, :country_code
    #add_index :addresses, [:lat, :lng]
    add_index :addresses, :created_at
  end
end

