# encoding: utf-8
class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins, :force => true do |t|
      t.string   :old_id,                 :limit => 36,  :null => false, :default => ""
      t.boolean  :active,                                :null => false, :default => true
      t.string   :civility,               :limit => 4,   :null => false, :default => :mr
      t.string   :first_name,             :limit => 64,  :null => false, :default => ""
      t.string   :last_name,              :limit => 64,  :null => false, :default => ""
      t.string   :phone_home,             :limit => 30,  :null => false, :default => ""
      t.string   :phone_mobile,           :limit => 30,  :null => false, :default => ""
      t.string   :phone_work,             :limit => 30,  :null => false, :default => ""
      t.string   :email,                  :limit => 80,  :null => false, :default => ""
      t.string   :encrypted_password,     :limit => 128, :null => false, :default => ""
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count,                         :null => false, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.integer  :failed_attempts,                       :null => false, :default => 0
      t.string   :unlock_token
      t.datetime :locked_at
      t.boolean  :admin,                                 :null => false, :default => false
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :admins, :old_id
    add_index :admins, [:first_name, :last_name]
    add_index :admins, :email
    add_index :admins, :reset_password_token
    add_index :admins, :confirmation_token
    add_index :admins, :unlock_token
    add_index :admins, :created_at
  end
end

