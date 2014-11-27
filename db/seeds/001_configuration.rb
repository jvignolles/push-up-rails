class Seeder
  def seed_configuration
    seeding "configuration"
    clear_table "configurations"
    cfg = Configuration.send(:new,
        :app_name => ENV["app_name"],
        :baseline => "",
        :email_contact => ENV["email_contact"],
        :company_name => ENV["company_name"],
        :phone => ENV["phone"],
        :fax => ENV["fax"],
        :address => ENV["address"],
        :quotation_description => "Nous vous recontactons au plus vite !",
        :newsletter_description => "Je m’abonne à la newsletter (une par mois) et je reste informé(e) des nouveautés",
        :website_on_hold => false,
        :website_on_hold_description => %(
          <p>Bonjour,</p>
          <p>Le site web est actuellement en maintenance, ce qui ne devrait durer que <strong>quelques minutes</strong>.</p>
          <p>Merci de votre compréhension.</p>
        ).strip.gsub(/^\s+/, ""),
    )
    cfg.save!
  end
end

