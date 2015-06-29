require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.automatic_reload = true
# Capybara.default_wait_time = 20

RSpec.configure do |config|
  # Capybara (http://stackoverflow.com/a/15148622)
  config.include Capybara::DSL
end
