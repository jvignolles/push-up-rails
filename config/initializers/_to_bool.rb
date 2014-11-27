# encoding: utf-8
module StringToBoolean
  def to_bool
    !!(self == true || self.to_s.strip =~ (/^(true|t|yes|y|1)$/i))
  end
end

class Object
  include StringToBoolean
end

class TrueClass
  def to_bool
    return self
  end
end

class FalseClass
  def to_bool
    return self
  end
end

