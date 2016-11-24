class Author < ActiveRecord::Base
  has_and_belongs_to_many :items
  before_save :update_hash_id

  def self.sanitise_name(name)
    name.gsub(/[^a-z ]/i, '').squish.downcase
  end

  def self.generate_hash(name)
    Digest::MD5.hexdigest("news-#{Author.sanitise_name(name)}")
  end

  private

  def update_hash_id
    self.hash_id = Author.generate_hash(name)
  end
end
