require 'rails_helper'

RSpec.describe Author, type: :model do
  describe '#create' do
    it 'saves the hash_id' do
      author = Author.create(name: 'max')
      expect(author.hash_id).to eq('278a6eab248d5113be1e3f8f14ce9a90')
    end
  end

  describe '#self.clean_up_blacklist' do
    it 'deletes any authors that are on the blacklist' do
      author_1 = Author.create(name: 'Guardian Sport')
      author_2 = Author.create(name: 'Source Reuters')
      author_3 = Author.create(name: 'Allowed')
      item_1 = FactoryGirl.create(:item)
      item_2 = FactoryGirl.create(:item)
      item_1.authors << author_1
      item_1.authors << author_2
      item_2.authors << author_1
      item_2.authors << author_3
      expect(item_1.authors.count).to eq(2)
      expect(item_2.authors.count).to eq(2)
      Author.clean_up_blacklist
      expect(item_1.authors.count).to eq(0)
      expect(item_2.authors.count).to eq(1)
    end
  end
end
