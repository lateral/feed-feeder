FactoryGirl.define do
  factory :key do
    key SecureRandom.hex
    endpoint 'http://api.lateral.io'
    purpose Faker::Lorem.sentence
  end

  factory :feed_source do
    url Faker::Internet.url
    key
  end

  trait :with_feeds do
    transient do
      number_of_feeds 3
    end

    after :create do |feed_source, evaluator|
      FactoryGirl.create_list :feed, evaluator.number_of_feeds, feed_source: feed_source
    end
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
    guid { SecureRandom.hex + '-' + Faker::Internet.url }
    published Faker::Date.between(6.days.ago, Date.today)
    author Faker::Name.name
    image Faker::Internet.url
    sent_to_api false
    body Faker::Lorem.paragraph(3)
  end
end
