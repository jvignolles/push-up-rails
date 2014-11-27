# encoding: utf-8
class CreateImages < ActiveRecord::Migration
  def change
    create_table :images, :force => true do |t|
      t.integer  :imageable_id
      t.string   :imageable_type, :limit => 32
      t.string   :content_type,   :limit => 32,                    :null => false
      t.integer  :position,                     :default => 0,     :null => false
      t.boolean  :assisted,                     :default => false, :null => false
      t.string   :kind,           :limit => 32
      t.boolean  :zoomable,                     :default => false, :null => false
      #t.string   :single_locale,  :limit => 2
      t.string   :img,                          :default => "",    :null => false
      t.text     :dimensions
      t.string   :legend,                       :default => "",    :null => false
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :images, [:imageable_id, :imageable_type]
    add_index :images, :kind
    add_index :images, :position
    #add_index :images, [:single_locale]
    add_index :images, :created_at
  end
end

