class Admin::ConfigurationsController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

  def index
    return redirect_to(edit_admin_configuration_path(@configuration))
  end

private
  def strong_params
    %w(
      app_name baseline email_contact company_name phone phone_hours fax address siret siren
      intracom_vat_number quotation_description newsletter_description
      seo_title seo_description seo_keywords website_on_hold website_on_hold_description
      facebook_url twitter_url googleplus_url instagram_url pinterest_url linkedin_url viadeo_url
    )
  end
end
