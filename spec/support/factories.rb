FactoryGirl.define do
  factory :user do
    uid { SecureRandom.uuid }
    email { Faker::Internet.email }
  end

  factory :story do
    association :user, factory: :user, email_verified: true
    alerts_enabled true
    title { Faker::Lorem.sentence }
    source_url { Faker::Internet.url }
    source_text { File.read(Rails.root.join('spec', 'fixtures', 'bbc-text.txt')) }
    threshold 0.629
  end

  factory :recommendation do
    association :story, factory: :story
    item_id %w(3012394 2954967 1576445 2928153 1651992 2989572 2922017 2917581 2924216).sample
    distance { rand(0.04...0.02) }
  end
end
