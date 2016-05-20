require 'rspec/expectations'

module FeedsHelper
  def feed_content(type)
    if type == :with_hub
      file = Dir.glob(Rails.root.join('spec/fixtures/feeds/*_hub.xml')).sample
    elsif type == :without_hub
      file = Dir.glob(Rails.root.join('spec/fixtures/feeds/*_nohub.xml')).sample
    elsif type == :random
      file = Dir.glob(Rails.root.join('spec/fixtures/feeds/*.xml')).sample
    elsif type == :with_relative_urls
      file = Dir.glob(Rails.root.join('spec/fixtures/feed-with-relative-urls.xml')).sample
    elsif type == :with_duplicates
      file = Dir.glob(Rails.root.join('spec/fixtures/feed-with-duplicates.xml')).sample
    elsif type == :with_plain_text_urls
      file = Dir.glob(Rails.root.join('spec/fixtures/feed-with-plain-text-urls.xml')).sample
    else
      file = Dir.glob(Rails.root.join("spec/fixtures/feeds/#{type}.xml")).sample
    end
    content = IO.read(file)
    doc = Nokogiri::XML content
    hub = doc.xpath("//*[@rel='hub']/@href")
    hub = hub[0] && hub[0].value.present? ? hub[0].value : nil
    rel_self = doc.xpath("//*[@rel='self']/@href")
    rel_self = rel_self[0] && rel_self[0].value.present? ? rel_self[0].value : nil
    OpenStruct.new url: rel_self, hub: hub, content: content
  end

  # Stubs the private run_python method of Feed model
  # Normally this would call a python script and parse the URL but
  # instead we just want to hijack it and return some random data
  def stub_feed_run_python_method(object = nil)
    allow_any_instance_of(Feed).to receive(:run_python) {
      object || {
        author: Faker::Name.name,
        body: Faker::Lorem.paragraph(3),
        image: Faker::Internet.url,
        keywords: Faker::Lorem.words(5),
        published: '',
        summary: Faker::Lorem.paragraph,
        title: Faker::Lorem.sentence,
        videos: [Faker::Internet.url]
      }
    }
  end
end

RSpec.configure do |config|
  config.include FeedsHelper
end
