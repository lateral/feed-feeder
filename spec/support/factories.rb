FactoryGirl.define do
  factory :feed_source do
    url 'https://superfeedr-blog-feed.herokuapp.com/'
  end

  factory :feed do
    url 'https://superfeedr-blog-feed.herokuapp.com/'
    feed_source
  end
end
