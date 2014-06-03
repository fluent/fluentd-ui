source 'https://rubygems.org'

gemspec

# spec.add_development_dependency gems doesn't installed by `gem install fluentd-ui`, but required them from config/application.rb, then error.
# this is workaround for that.
group :development, :test do
  gem "rake"
  gem "pry"
  gem "rspec-rails", "~> 3.0"
end

group :test do
  gem "factory_girl_rails"
  gem "database_cleaner", "~> 1.2.0"
  gem "capybara", "~> 2.2.1"
  gem "simplecov", "~> 0.7.1", require: false
  gem "webmock", "~> 1.18.0"
end
