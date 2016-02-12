require 'rspec/expectations'

module FeedsHelper
  def feed_content(type)
    if type == :with_hub
      file = Dir.glob(Rails.root.join('spec/fixtures/feeds/*_hub.xml')).sample
    elsif type == :without_hub
      file = Dir.glob(Rails.root.join('spec/fixtures/feeds/*_nohub.xml')).sample
    elsif type == :random
      file = Dir.glob(Rails.root.join('spec/fixtures/feeds/*.xml')).sample
    else
      file = Dir.glob(Rails.root.join("spec/fixtures/feeds/#{type}.xml")).sample
    end
    content = IO.read(file)
    feed = Feedjira::Feed.parse content
    OpenStruct.new url: feed.url, hub: feed.hubs.first, content: content
  end
end

RSpec.configure do |config|
  config.include FeedsHelper
end
