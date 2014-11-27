# encoding: utf-8
class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string   :old_id,        :limit => 36, :default => "",    :null => false
      t.boolean  :active,                      :default => true,  :null => false
      t.string   :code,          :limit => 2
      t.string   :name,          :limit => 50, :default => "",    :null => false
      t.string   :english_name,  :limit => 50, :default => "",    :null => false
      t.string   :currency_code, :limit => 3
      t.boolean  :uses_vat,                    :default => true,  :null => false
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :countries, :old_id
    add_index :countries, :code
    add_index :countries, :name
    add_index :countries, :created_at
  end
end

