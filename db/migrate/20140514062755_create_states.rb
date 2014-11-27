# encoding: utf-8
class CreateStates < ActiveRecord::Migration
  def change
    create_table :states, :force => true do |t|
      t.boolean  :active,                      :default => true,   :null => false
      t.string   :country_code, :limit => 2,   :default => "FR",   :null => false
      t.integer  :region_id
      t.string   :code,         :limit => 16,  :default => "",     :null => false
      t.string   :name,         :limit => 50,  :default => "",     :null => false
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :states, :region_id
    add_index :states, :code
    add_index :states, :name
    add_index :states, :created_at
  end
end

