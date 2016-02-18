# apps/models/key.rb
class Key < ActiveRecord::Base
  has_many :feed_sources
end
