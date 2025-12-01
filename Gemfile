source "https://rubygems.org"

ruby "3.4.7"
gem "rails", "~> 8.1.1"
gem "propshaft"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  gem "sqlite3", ">= 2.1"
end

group :production do
  gem "pg", "~> 1.5"
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner-active_record'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', '~> 5.0'
end

gem "tzinfo-data", platforms: %i[ mswin64 mingw x64_mingw jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem 'simplecov', require: false, group: :test
gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri mswin64 mingw x64_mingw ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "cucumber-rails", require: false
  gem "database_cleaner-active_record"
end
