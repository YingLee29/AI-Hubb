source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.1"

gem "rails", "~> 7.0.5"
gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"
gem "jbuilder"
gem 'dotenv-rails'
gem 'public_uid'
gem 'bootstrap'
gem "font-awesome-sass", "~> 6.4.0"
gem 'devise', '~> 4.9', '>= 4.9.2'
gem 'ransack', '~> 3.2.1'
gem 'kaminari'
gem 'bootstrap5-kaminari-views'
gem "importmap-rails"
gem "gretel"
gem 'rubyzip'

gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "sassc-rails"
gem "jquery-rails"
gem "ruby-openai"
gem "down", "~> 5.0"
gem 'httparty'
gem 'acts_as_tenant'
gem 'rails-i18n'
gem 'multibyte', '~> 0.1.1'
gem 'rack-cors'


group :development, :test do
  gem 'letter_opener_web', '~> 2.0'
  gem 'pry-rails'
end

group :development do
  gem 'capistrano'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem "web-console"
  gem 'capistrano3-puma'
  # Should already be in your Gemfile
  gem 'capistrano-rails'

  gem 'capistrano-bundler'

  gem 'capistrano-dotenv'
  gem 'capistrano-rbenv'
  gem 'annotate'
  gem 'sshkit-sudo'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
