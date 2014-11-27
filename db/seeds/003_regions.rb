class Seeder
  REGIONS = [
    [1,  'FR', 'Île-de-France'],
    [2,  'FR', 'Champagne-Ardenne'],
    [3,  'FR', 'Picardie'],
    [4,  'FR', 'Haute-Normandie'],
    [5,  'FR', 'Centre'],
    [6,  'FR', 'Basse-Normandie'],
    [7,  'FR', 'Bourgogne'],
    [8,  'FR', 'Nord-Pas-de-Calais'],
    [9,  'FR', 'Lorraine'],
    [10, 'FR', 'Alsace'],
    [11, 'FR', 'Franche-Comté'],
    [12, 'FR', 'Pays de la Loire'],
    [13, 'FR', 'Bretagne'],
    [14, 'FR', 'Poitou-Charentes'],
    [15, 'FR', 'Aquitaine'],
    [16, 'FR', 'Midi-Pyrénées'],
    [17, 'FR', 'Limousin'],
    [18, 'FR', 'Rhône-Alpes'],
    [19, 'FR', 'Auvergne'],
    [20, 'FR', 'Languedoc-Roussillon'],
    [21, 'FR', 'Provence-Alpes-Côte d’Azur'],
    [22, 'FC', 'Corse'],
    [23, 'GP', 'Guadeloupe'],
    [24, 'MQ', 'Martinique'],
    [25, 'GF', 'Guyane'],
    [26, 'RE', 'La Réunion'],
    [27, 'YT', 'Mayotte'],
    [28, 'MC', 'Monaco'],
  ].freeze

  def seed_regions
    seeding 'regions'
    clear_table 'regions'
    progress do
      now = Time.now.to_s(:db)
      REGIONS.each do |region|
        values_clause = (region + [1, now, now]).map { |v| cnx.quote(v) }.join(', ')
        sql = "INSERT INTO regions (id, country_code, name, active, created_at, updated_at) VALUES (#{values_clause})"
        cnx.insert(sql)
        ahead!
      end
    end
  end
end

