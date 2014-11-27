module FormatMethods
  def format_civility(civility, format = :short)
    format = :short unless [:short, :long].include?(format.to_sym)
    I18n.t("civilities.#{civility}.#{format}")
  end

  # Formats a date (no time part).  Possible formats: +:short+ (equivalent to locale’s +:default+)
  # and :long (equivalent to locale’s +:full+).  Anything else is taken as +:short+.  Empty string
  # if date is blank.
  def format_date(date, format = :short)
    return '' if date.blank?
    date = date.to_date unless date.is_a?(Date)
    format = { :short => :default, :long => :full}[format] || :default
    I18n.localize(date, :format => format)
  end

  # Formats a Time or DateTime using the locale’s +:medium+ format
  # (e.g. in our fr.yml, '%d/%m/%Y à %H:%M').  Empty string if time is blank.
  def format_datetime(time, format = :medium)
    return '' if time.blank?
    I18n.localize(time, :format => format)
  end

  def format_phone(phone)
    I18n.format_phone(phone)
  end

  def format_price_cents(cents)
    format_price_value(cents / 100.0)
  end

  def format_price_value(price)
    s = price.to_s.gsub(/[^0-9.,]+/, "").gsub(".", "").sub(",", ".")
    "#{s} €"
  end
end
