# app/models/feed_source.rb
class FeedSource < ActiveRecord::Base
  has_many :items
  has_many :feeds
  belongs_to :key
end
