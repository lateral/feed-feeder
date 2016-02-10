require 'rspec/expectations'

module FeedsHelper
  def feed_content(type)
    if type == :with_hub
      IO.read(Rails.root.join('spec/fixtures/feeds/superfeedr.xml'))
    end
  end
end

RSpec.configure do |config|
  config.include FeedsHelper
end
