# require 'sidekiq/web'

Rails.application.routes.draw do
  #root to: 'front::home#index', format: false
  #get '/', to: 'front::home#index', as: 'home', format: false
  localized do
    draw :front
  end
  draw :admin
  get '/maintenance', to: 'application#on_hold', as: 'on_hold', format: false
  %w(404 422 500).each do |code|
    get code, to: "errors#show", code: code, format: false
  end
end

# DEV NOTE: all routes above are translated
#ActionDispatch::Routing::Translator.translate_from_file(
#  I18n.available_locales.map { |locale| "config/locales/routes/#{locale}.yml" },
#  { :no_prefixes => true } # TODO: use default locales instead of custom /:locale ?
#)
