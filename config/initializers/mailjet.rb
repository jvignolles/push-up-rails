# encoding: utf-8
# Be sure to restart your server when you modify this file.
Mailjet.configure do |config|
  config.api_key =      ENV["mailjet_api_key"]    if ENV["mailjet_api_key"].present?
  config.secret_key =   ENV["mailjet_secret_key"] if ENV["mailjet_secret_key"].present?
  config.default_from = ENV["email_contact"]      if ENV["email_contact"].present?
end

