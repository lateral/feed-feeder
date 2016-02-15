# app/models/item.rb
class Item < ActiveRecord::Base
  belongs_to :feed_source
  belongs_to :feed
end
