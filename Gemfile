source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

## MOVE dotenv TO TOP AND REQUIRE:
# gem 'dotenv-rails', require: 'dotenv/rails-now'
# gem 'dotenv-rails', groups: [:development, :test]


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1', '>= 5.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  ## STANDARD DEFAULT BELOW:
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'

  ## SDF CUSTOM BELOW:
  ## NONE
end

group :development do
  ## STANDARD DEFAULT BELOW:
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  ## SDF CUSTOM BELOW:
  # gem 'rainbow', '~> 3.0'
  gem 'pry', '~> 0.11.3'

  gem 'sidekiq', '~> 5.0', '>= 5.0.5'
  # gem 'sinatra', require: false
  gem 'slim', '~> 3.0', '>= 3.0.9'
  # gem 'thin', '~> 1.7'

  # Use Redis adapter to run Action Cable in production
  gem 'redis', '~> 3.3', '>= 3.3.1'

  ## This is attempt to replace daemons for multiple workers.
  #gem 'delayed_job_worker_pool', '~> 0.2.3'

end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


## SDF GEMS:
gem 'activerecord-import', '~> 0.21.0'
# Use hirb for rails c table view.  Then in rails c:
gem 'hirb', '~> 0.7.3'
# require 'hirb'
# Hirb.enable

gem 'will_paginate', '~> 3.1', '>= 3.1.6'
gem 'will_paginate-bootstrap4'

gem 'daemons', '~> 1.2', '>= 1.2.5'
gem 'delayed_job_active_record', '~> 4.1', '>= 4.1.2'
gem 'delayed_job_web', '~> 1.4'
gem 'delayed_job', '~> 4.1', '>= 4.1.3'
gem 'mechanize', '~> 2.7', '>= 2.7.5'
gem 'geocoder', '~> 1.4', '>= 1.4.5'
gem 'google_custom_search_api', '~> 2.0'
gem 'google_places', '~> 1.0'
gem 'gmaps4rails', '~> 2.1', '>= 2.1.2'
gem 'underscore-rails', '~> 1.8', '>= 1.8.3'
gem 'devise', '~> 4.3'
gem 'figaro', '~> 1.1', '>= 1.1.1'
gem 'curb', '~> 0.9.4'
# gem 'curb', '~> 0.9.3'
# gem 'curb'
gem 'whois', '~> 4.0', '>= 4.0.5'
gem 'chartkick', '~> 2.2', '>= 2.2.5'
gem 'foreman', '~> 0.84.0'
# gem 'whenever', require: false
###############

## Adam's DBC Gems ##
# gem 'bcrypt'
# gem 'faker'
# gem 'rspec', '~>3.0'

gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.2'
gem 'font-awesome-sass', '~> 4.7.0'
# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.3', '>= 4.3.1'
gem 'bootstrap', '~> 4.0.0.beta2.1'
gem 'autoprefixer-rails'
gem 'net-ping', '~> 1.7', '>= 1.7.8'
gem 'openssl', '~> 2.0.0.beta.1'
# gem 'pg_search', '~> 2.1', '>= 2.1.1'
# gem 'stripe', '~> 3.9'
gem 'ransack', '~> 1.8', '>= 1.8.4'
# gem 'aws-sdk', '~> 1.6'
# gem 'paperclip', '~> 5.1'
# gem 'google-api-client', '~> 0.18.0'
# gem 'geokit', '~> 1.11'

## Sample - Testing this gem below:
# gem 'final_fwd_url', '~> 0.1.0'

gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'

# gem 'will_filter'
# gem 'kaminari'
