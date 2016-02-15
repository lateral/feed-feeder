# apps/models/key.rb
class Key < ActiveRecord::Base
  has_and_belongs_to_many :feed_sources
end
