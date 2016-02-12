FactoryGirl.define do
  factory :feed_source do
    url Faker::Internet.url
  end

  factory :feed do
    url Faker::Internet.url
    feed_source
  end
end
