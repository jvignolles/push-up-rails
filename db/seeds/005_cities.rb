require "csv"

class Seeder
  CSV_FILENAME = "cities.csv"

  def seed_cities
    seeding "cities"
    clear_table "cities"
    progress do
      states = State.all.inject({}) { |acc, s| acc[s.code.to_i] = s.id; acc }
      now = Time.zone.now.to_s(:db)
      CSV.parse(File.read(File.join(Rails.root, "db", "seeds", "cities", CSV_FILENAME)), :headers => false, :col_sep => ";").each do |row|
        zip_code = row[1]
        zip_code = "0#{zip_code}" unless zip_code =~ /^\d{5}/
        cedex = (zip_code =~ /CEDEX/i || zip_code =~ /SP/) ? "1" : "0"
        state_code = row[3].to_s
        state_id = states[state_code]
        fake = ("1" == row[6].to_s)
        arr = row[7].to_s
        if arr.present?
          state_code = zip_code
        end
        #state_id = 20 if state_id =~ /2[AB]/
        values_clause = [cedex, state_id, zip_code, row[2], row[4], row[5], now, now, fake, arr].map { |v| cnx.quote(v) }.join(', ')
        sql = "INSERT INTO cities (cedex, state_id, zip_code, name, lat, lng, created_at, updated_at, fake_city, arrondissement) VALUES (#{values_clause})"
        cnx.insert(sql)
        ahead!
      end
    end
  end
end

