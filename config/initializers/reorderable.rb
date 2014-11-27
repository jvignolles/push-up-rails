# encoding: utf-8
module Reorderable
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def reorderable(opts = {})
      opts[:method_name] ||= :position
      opts[:foreign_key] ||= :id
      instance_eval %(
        before_create :set_position

        scope :ordered, -> { order("\#{self.name.tableize}.#{opts[:method_name]}, \#{self.name.tableize}.id") }

        def self.ordered_list
          find(:all).order("#{self.name.tableize}.#{opts[:method_name]}, #{self.name.tableize}.id")
        end

        def self.reorder(id_list)
          transaction do
            id_list.each_with_index do |id, index|
              where(:"#{opts[:foreign_key]}" => id).update_all(:"#{opts[:method_name]}" => index + 1)
            end
          end
        end
      )
      class_eval %(
        def set_position
          if #{opts[:method_name]}.to_i <= 0
          #{opts[:scope].nil? ? %(
            self.#{opts[:method_name]} = (self.class.maximum("#{opts[:method_name]}") || 0) + 1
          ) : %(
            self.#{opts[:method_name]} = if #{opts[:scope]}
              (self.class.where("#{opts[:scope]}" => #{opts[:scope]}).maximum("#{opts[:method_name]}") || 0) + 1
            else
              0
            end
          )}
          end
          true
        end
      )
    end
  end
end

ActiveRecord::Base.send :include, Reorderable

