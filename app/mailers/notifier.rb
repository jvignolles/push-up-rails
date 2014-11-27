class Notifier < ActionMailer::Base
  include ApplicationHelper
  add_template_helper(ApplicationHelper)

  layout "notifier"

  default from: Proc.new { format_recipient(email_contact, app_name) }, charset: "utf-8"

# FRONT
  def contact(opts)
    otps ||= {}
    opts.symbolize_keys!
    @email_info ||= {}
    @email_info.merge! opts
    contact = opts[:contact]
    return unless contact
    @configuration ||= ::Configuration.instance
    @email_info[:subject] = "Message de #{contact.name}"
    @email_info[:description] = contact.description
    mail(
      :to => format_recipient(email_contact, app_name),
      :reply_to => format_recipient(contact.email, contact.name),
      :subject => "[#{app_name}] #{@email_info[:subject]}"
    )
  end

  def quotation(opts)
    otps ||= {}
    opts.symbolize_keys!
    @email_info ||= {}
    @email_info.merge! opts
    quotation = opts[:quotation]
    return unless quotation
    @configuration ||= ::Configuration.instance
    @email_info[:subject] = "Demande de devis de #{quotation.name}"
    @email_info[:description] = quotation.description
    mail(
      :to => format_recipient(email_contact, app_name),
      :reply_to => format_recipient(quotation.email, quotation.name),
      :subject => "[#{app_name}] #{@email_info[:subject]}"
    )
  end

# DEVISE
  def confirmation_instructions(h)
    h = h.symbolize_keys # don't use symbolize_keys!
    return if cannot_send_email(h[:recipient_email])
    @configuration ||= ::Configuration.instance
    @email_info = h
    @email_info[:subject] ||= "#{h[:recipient_name]}, confirmez votre adresse e-mail"
    mail(:to => format_recipient(h[:recipient_email], h[:recipient_full_name]),
         :subject => @email_info[:subject],
         :template_name => "devise_confirmation_instructions")
  end

  def reset_password_instructions(h)
    h = h.symbolize_keys # don't use symbolize_keys!
    return if cannot_send_email(h[:recipient_email])
    @configuration ||= ::Configuration.instance
    @email_info = h
    @email_info[:subject] ||= "#{h[:recipient_name]}, modifiez votre mot de passe"
    mail(:to => format_recipient(h[:recipient_email], h[:recipient_full_name]),
         :subject => @email_info[:subject],
         :template_name => "devise_reset_password_instructions")
  end

private
  def cannot_send_email(recipient_email)
    recipient_email.blank?
  end

  def format_recipient(email, name = nil)
    Rails.env.production? ? (name.blank? ? email : "#{name} <#{email}>") : Figaro.env.email_contact
  end
end
