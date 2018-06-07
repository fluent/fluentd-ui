# Load the Rails application.
require_relative 'application'

# Load fluentd libraries & plugins
require "fluent/load"

# Initialize the Rails application.
Rails.application.initialize!
