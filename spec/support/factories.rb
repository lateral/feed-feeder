FactoryGirl.define do
  factory :feed_source do
    url Faker::Internet.url
  end

  factory :feed do
    url Faker::Internet.url
    feed_source
  end

  factory :item do
    feed_source
    url Faker::Internet.url
    title Faker::Lorem.sentence
    summary Faker::Lorem.paragraph
    guid Faker::Internet.url
    author Faker::Name.name
    image Faker::Internet.url
    sent_to_api false
    body Faker::Lorem.paragraph(3)
  end
end
