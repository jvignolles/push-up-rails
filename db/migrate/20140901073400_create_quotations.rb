# encoding: utf-8
class CreateQuotations < ActiveRecord::Migration
  def change
    create_table :quotations, :force => true do |t|
      t.string   :first_name, :limit => 128, :null => false, :default => ""
      t.string   :last_name,  :limit => 80,  :null => false, :default => ""
      t.string   :email,      :limit => 128, :null => false, :default => ""
      t.string   :phone,      :limit => 20,  :null => false, :default => ""
      t.string   :from_path
      t.text     :description
      t.integer  :product_id
      t.integer  :admin_id
      t.datetime :answered_at
      t.integer  :answerer_id
      t.integer  :latest_answer_id
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :quotations, [:first_name, :last_name, :email]
    add_index :quotations, :created_at
  end
end

