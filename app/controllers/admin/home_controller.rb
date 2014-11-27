class Admin::HomeController < Admin::BaseController
  def index
    now = Time.now.beginning_of_day
    @metrics = [
      { name: "Contacts ces 7 derniers jours", icon: "comment", url: admin_contacts_path,
        value: Contact.since(now - 7.days).length },
      { name: "Contacts à traiter", icon: "envelope", url: admin_contacts_path,
        value: Contact.waiting.length },
    ]
    init_view
  end

  def email_layout
    @configuration ||= ::Configuration.instance
    @email_info ||= {}
    @email_info[:subject] = "Bienvenue sur #{app_name}"
    @email_info[:description] = "#{app_name} vous souhaite la bienvenue, voici vos identifiants."
    @email_info[:archive_link] = "http://#{Figaro.env.site_tld}"
    @email_info[:baseline] = @configuration.baseline
    @email_info[:recipient_email] = Figaro.env.email_contact
    #@email_info[:sidebar] = true
    render layout: "notifier", inline: %(<p>coucou !</p><p>Il s'agit d'un test avec potentiellement plusieurs lignes d'explications. Tout ça pour ça, c'est complètement génial et tout et tralala.</p><div class="button-wrapper"><a href="#{front_home_path}" class="button">Découvrir #{app_name}</a></div>)
  end

private
  def init_view
    # TODO
  end
end
