# encoding: utf-8
class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :team_members, :force => true do |t|
      t.boolean  :active,                     :null => false, :default => true
      t.string   :civility,    :limit => 4,   :null => false, :default => :mr
      t.string   :first_name,  :limit => 128, :null => false, :default => ""
      t.string   :last_name,   :limit => 128, :null => false, :default => ""
      t.text     :description
      t.integer  :position,                   :null => false, :default => 0
      # Rails dates
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :team_members, [:first_name, :last_name]
    add_index :team_members, :position
    add_index :team_members, :created_at
  end
end

