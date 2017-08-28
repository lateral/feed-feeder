class Author < ActiveRecord::Base
  has_and_belongs_to_many :items
  before_save :update_hash_id

  def self.sanitise_name(name)
    name.gsub(/[^a-z ]/i, '').squish.downcase
  end

  def self.generate_hash(name)
    Digest::MD5.hexdigest("news-#{Author.sanitise_name(name)}")
  end

  def self.clean_up_blacklist
    AUTHORS_BLACKLIST['hash_ids'].each do |hash_id|
      authors = Author.where(hash_id: hash_id)
      AuthorItem.where(author_id: authors.map(&:id)).delete_all
      authors.delete_all
    end
    AUTHORS_BLACKLIST['name_start_match'].each do |prefix|
      authors = Author.where("name LIKE :prefix", prefix: "#{prefix}%")
      AuthorItem.where(author_id: authors.map(&:id)).delete_all
      authors.delete_all
    end
  end

  private

  def update_hash_id
    self.hash_id = Author.generate_hash(name)
  end
end
