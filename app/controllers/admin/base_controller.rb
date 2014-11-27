class Admin::BaseController < ApplicationController
  include AdminLayout # See /app/concerns/admin_layout.rb
  include Admin::BaseHelper

  alias_method :current_user, :current_admin

  layout "admin_intern"

  MENU = {
    home:           { name: "Accueil",         url: "admin_home_path" },
    homepage:       { name: "Page d’accueil",  url: "", children: {
      banners:        { name: "Bannières",       url: "admin_banners_path" },
      highlights:     { name: "Mises en avant",  url: "admin_highlights_path" },
    }},
    prospects:      { name: "Prospection",     url: "", children: {
      contacts:       { name: "Demandes de contact",     url: "admin_contacts_path", badge: "@badge_contacts", badge_kind: "warning" },
      quotations:     { name: "Demandes de devis",       url: "admin_quotations_path", badge: "@badge_quotations", badge_kind: "warning" },
      subscriptions:  { name: "Inscriptions newsletter", url: "admin_subscriptions_path", badge: "@badge_subscriptions", badge_kind: "success" },
    }},
    products:       { name: "Produits",        url: "admin_products_path" },
    editorials:     { name: "Éditoriaux",      url: "admin_editorials_path" },
    #team_members:   { name: "L’équipe",        url: "admin_team_members_path" },
    #lists:          { name: "Listes",          url: "", children: {
    #  countries:      { name: "Pays",                                                       url: "admin_countries_path" },
    #  countries:      { name: "Pays",              condition: "current_admin.admin?",       url: "admin_countries_path" },
    #}},
    configurations: { name: "Configuration",   url: "admin_configurations_path", condition: "current_admin.admin?" },
    admins:         { name: "Administrateurs", url: "admin_admins_admins_path" },
  }
end
