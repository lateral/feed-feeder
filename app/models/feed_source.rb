# app/models/feed_source.rb
class FeedSource < ActiveRecord::Base
  has_many :items
end
