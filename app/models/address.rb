#require 'geocode_worker'

class Address < ActiveRecord::Base
  strip_fields :address, :city_name, :zip_code

  #before_validation :sync_city_id, :update_country_code
  before_validation :cleanup_french_zip_code

  # TODO: validates
  # TODO: what if geocode throw an error?!

  #belongs_to :x_city, class_name: "City", foreign_key: "city_id"
  has_one :contact

  unless const_defined?(:FRENCH_OVERSEAS_DEPARTMENTS)
    FRENCH_OVERSEAS_DEPARTMENTS = {
      "20"  => "FC", # 240 - Corse - not DOM/TOM but sometimes with a different pricing
      "971" => "GP", #  84 - Guadeloupe
      "972" => "MQ", # 143 - Martinique
      "973" => "GF", #  78 - Guyane Française
      "974" => "RE", # 181 - La Réunion
      "975" => "PM", # 173 - Saint-Pierre-et-Miquelon
      "976" => "YT", # 236 - Mayotte
      "980" => "MC", # 133 - Monaco, OK, actually not an oversea department
      "984" => "TF", # 206 - Terres Australes et Antarctiques
      "986" => "WF", # 233 - Wallis et Futuna
      "987" => "PF", # 168 - Polynésie Française
      "988" => "NC", # 154 - Nouvelle-Calédonie
    }
  end

  def actual_country_code
    FRENCH_OVERSEAS_DEPARTMENTS.values.include?(country_code) ? "FR" : country_code
  end

  def country(reload = false)
    @country = nil if reload
    @country ||= Country.find_by_code(country_code.to_s)
  end

  def country_code_name
    @country_code_name ||= I18n.t("c_#{country_code.to_s.upcase}", scope: :countries, default: country_code)
  end

  def country_fullname
    country_code_name.present? ? country_code_name : country_name
  end

  def city_fullname
    # TODO city ? city.name : city_name
    city_name
  end

  def to_s
    # TODO [address, complement, "#{zip_code} #{city_fullname}", country_fullname].reject(&:blank?).map(&:strip).join(", ")
    [address, complement, "#{zip_code} #{city_fullname}"].reject(&:blank?).map(&:strip).join(", ")
  end

  #def from_geocode
  #  geocode = lat.present? && lng.present? ? nil : nil
  #end

  #def geocode
  #  coords = Geocoder.coordinates(Ascii.convert(to_s))
  #  self.calculated_geolocation = true
  #  return nil if coords.blank? || coords.first.blank? || coords.last.blank?
  #  self.lat = coords.first if coords.first.present?
  #  self.lng = coords.last if coords.last.present?
  #  coords
  #end

  #def geocode!
  #  geocode
  #  save!
  #end

  SEARCH_DEFAULT_SORTING = "name-asc"
  SEARCH_SORTING = {
    "name" => "companies.name",
    "created" => "companies.created_at",
  }
  scope :order_by, ->(*opts) {
    opts = opts.is_a?(Hash) ? opts.extract_options!.symbolize_keys : { :order => (opts || '').to_s }
    opts[:default] ||= SEARCH_DEFAULT_SORTING
    by, order = (opts[:s] || "").split("-")
    by = opts[:default].split("-").first unless SEARCH_SORTING.has_key?(by)
    order = opts[:default].split("-").last unless ["asc", "desc"].include?(order)
    #includes(:company).
    order("#{SEARCH_SORTING[by]} #{order}")
  }
  #scope :geocoded, -> { # Override geocoder's scope: need table name
  #  where(["addresses.lat is not null and addresses.lng is not null"])
  #}
  scope :for_city, ->(opts) {
    opts = [opts].flatten.map(&:to_i).reject(&:blank?)
    next where(nil) if opts.blank?
    where(["addresses.city_id in (?)", opts])
  }
  scope :for_state, ->(opts) {
    next where(nil) if opts.to_i.blank?
    #.includes(:cities)
    where(["cities.state_id = ?", opts.to_i])
  }
  scope :for_text, ->(opts) {
    words = opts && opts.scan(/\w+/)
    next where(nil) if words.blank?
    conditions = ["true"]
    joins = " INNER JOIN companies aft_c ON (aft_c.id = addresses.company_id) LEFT OUTER JOIN pros aft_p ON (aft_c.id = aft_p.company_id)"
    words.each do |word|
      conditions[0] += " AND (false"
      #["aft_c.name", "addresses.address", "addresses.zip_code", "addresses.city", "aft_p.first_name", "aft_p.last_name"].each do |field|
      ["aft_c.name", "aft_p.first_name", "aft_p.last_name"].each do |field|
        conditions[0] += " OR #{field} like ?"
        conditions << "%#{word}%"
      end
      conditions[0] += ")"
    end
    where(conditions).joins(joins).group("addresses.id")
  }
  scope :searchable, -> {
    where(["companies.validation_status = ? and companies.appears_on_search = ?", :validated, true])
  }

  def self.injecting!
    @__injecting = true
  end

  def self.injecting?
    !!@__injecting
  end

  def self.injecting_done!
    @__injecting = false
  end

private
  def cleanup_french_zip_code
    if "FR" == actual_country_code
      # Usual erroneous input normalizations: dept-digits-only or missing-third-zero
      v = zip_code.to_s.gsub(/O/i, '0')
      v = "#{v}000" if v[/^\d{2}$/]
      v = "#{v}0" if v[/^\d{2}00$/]
      self.zip_code = v
    end
    true
  end

  def strip_for_levenstein(str)
    str.parameterize.downcase.gsub(/[^a-z]+/, "")
  end

  def sync_city_id
    if zip_code_changed? || city_changed?
      cities = [City.where(["zip_code = ? and cedex = ?", zip_code, false]).order("cities.zip_code, cities.name").all].flatten.reject(&:blank?)
      canonical_city_name = strip_for_levenstein(city)
      r = cities.inject([2, nil]) { |acc, c|
        n = strip_for_levenstein(c.name)
        l = Levenshtein.normalized_distance(canonical_city_name, n)
        acc = [l, c.id] if l < acc[0]
        acc
      }[1]
      self.city_id = r
    end
    true
  end

  def update_country_code
    self.zip_code = zip_code.to_s.strip
    country_code = self.country_code.to_s.upcase
    return true unless (zip_code_changed? || Address.injecting?) &&
      (["FR"] + FRENCH_OVERSEAS_DEPARTMENTS.values).include?(country_code) &&
      zip_code =~ /^9[78]/
    FRENCH_OVERSEAS_DEPARTMENTS.each do |zip_code_beginning, country_code|
      next unless zip_code.starts_with?(zip_code_beginning)
      self.country_code = country_code
      break
    end
    true
  end
end
