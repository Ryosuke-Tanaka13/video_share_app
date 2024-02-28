# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'
Rails.application.configure do
  config.logger = Logger.new(STDOUT)
end

# Initialize the Rails application.
Rails.application.initialize!
