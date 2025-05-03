source 'https://rubygems.org'

gemspec

# spec.add_development_dependency gems doesn't installed by `gem install fluentd-ui`, but required them from config/application.rb, then error.
# this is workaround for that.
group :development, :test do
  gem "rake"
  gem "pry"
  gem "pry-rails"
  gem "test-unit-rails"
  gem "test-unit-notify"
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'i18n_generators', '2.1.1'
  gem 'better_errors', '>= 2.8.0'
  gem 'web-console', '~> 3.6'
  gem 'binding_of_caller'
end

group :test do
  gem "factory_bot_rails"
  gem "capybara", "~> 3.4.2"
  gem "capybara-screenshot"
  gem "webdrivers"
  gem "simplecov", "~> 0.16.1", require: false
  gem "webmock", "~> 3.12.2"
  gem "timecop"
  gem "selenium-webdriver", "~> 3.13.1"
end
