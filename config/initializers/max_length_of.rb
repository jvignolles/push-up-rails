# encoding: utf-8
module MaxlengthOf
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def maxlength_of(method_name)
      return 255 unless table_exists?
      if column = columns_hash[method_name.to_s]
        column.text? ? column.limit : nil
      end
    end
  end
end

class ActiveRecord::Base
  include MaxlengthOf
end

