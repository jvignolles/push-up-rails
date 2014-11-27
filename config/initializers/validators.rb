# encoding: utf-8
# Be sure to restart your server when you modify this file.
class EmailValidator < ActiveModel::EachValidator
  REG_EMAIL = Regexp.new( # The following pattern matches about 99.99% of actual uses.
      '^[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*' +
      '@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$', 'i')

  def validate_each(record, attribute, value)
    unless value =~ REG_EMAIL
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.invalid'))
    end
  end
end

# Sync it with validator.js
class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    error = false
    begin
      number = GlobalPhone.parse(value, I18n.territory_name)
      if !number || !number.valid? ||
          (I18n.territory_name == number.territory.name.to_s.upcase && !!(number.national_string =~ I18n.t('mobile_format')))
        error = true
      end
    rescue
      error = true
    end
    if error
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.invalid'))
    end
  end
end

# Sync it with validator.js
class MobileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    error = false
    begin
      number = GlobalPhone.parse(value, I18n.territory_name)
      error = true if !number || !number.valid? ||
          (I18n.territory_name == number.territory.name.to_s.upcase && !(number.national_string =~ I18n.t('mobile_format')))
    rescue
      error = true
    end
    if error
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.invalid'))
    end
  end
end

class MaxlengthAutoValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless record.class.table_exists?
    max = record.class.maxlength_of(attribute)
    if max < value.to_s.mb_chars.size
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.too_long', :count => max))
    end
  end
end

