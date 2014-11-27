source 'https://rubygems.org'
ruby ENV['CUSTOM_RUBY_VERSION'] || '2.1.2'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.7'

# SGBD
#gem 'sqlite3'
gem 'mysql', '2.9.1'
gem 'mysql2', '>= 0.3.13'


gem 'haml-rails'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jcrop-rails-v2'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
# gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Application configuration, see config/application.yml
gem 'figaro', '~> 0.7.0'

# Utilities
gem 'unicode_utils'
gem 'escape_utils'
gem 'levenshtein'
gem 'htmlentities'

# Forms
gem 'dynamic_form'
gem 'simple_form'

# Authentication
# DEV NOTE: version fixed! Few customizations on views and controllers.
gem 'devise'
gem 'cancan'

# Pagination
gem 'will_paginate', '3.0.4'
gem 'bootstrap-will_paginate', '0.0.9'

# Images
gem 'carrierwave', '~> 0.10.0'  # File uploads and image thumbnailing (requires one of many options, here mini_magick)
gem 'carrierwave_direct'
gem 'fog', '1.22.1'  # TODO: v1.25.0 use AWS SignatureV4, and there's something wrong with it…
gem 'mime-types'  # MIME detection for CarrierWave and others
gem 'mini_magick', '~> 3.4'  # Image processing

# Geocoding
gem 'geocoder'

# Routes translation
#gem 'rails-translate-routes'
gem 'route_translator'

# URL redirections
gem 'rack-rewrite', '~> 1.5.0'  # middleware url rewriting (avoid Apache mod rewrite)

# Sidekiq
# DEV NOTE: version fixed! Apache configuration on production server MUST match Sidekiq directory assets:
# cf. /etc/apache2/sites-enabled/001-myvirtualhost.com.conf: XSendFilePath line.
gem 'sidekiq', '2.17.7'
gem 'sidekiq-lock', '~> 0.2.0'
gem 'sinatra', require: false

# Mails
gem 'mailjet', '0.0.5'

# Exception mails
gem 'exception_notification'
gem 'premailer-rails'
gem 'nokogiri'

# Newrelic should support Sidekiq but, care, stack overflow!!!
gem 'newrelic_rpm'

# Assets
gem 'bourbon',                '3.1.1'  # DEV NOTE: version fixed! We only import required functions (cf. _mixins.scss).
gem 'select2-rails'
gem 'tinymce-rails'
gem 'tinymce-rails-langs'
gem 'magnific-popup-rails'
gem 'jquery-fileupload-rails', github: 'jvignolles/jquery-fileupload-rails.git'
gem 'notifyjs_rails'


# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

group :development do
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'sextant'

  # Capistrano
  # gem 'capistrano', '~> 2.15.0', require: false
  # gem 'capistrano-detect-migrations', require: false

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# Heroku
group :production do
  gem 'rails_12factor'

  # Gzip compression for assets (but not images)
  gem 'heroku-deflater'
end

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]

