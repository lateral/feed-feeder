require 'rails_helper'

RSpec.describe Author, type: :model do
  describe '#create' do
    it 'saves the hash_id' do
      author = Author.create(name: 'max')
      expect(author.hash_id).to eq('278a6eab248d5113be1e3f8f14ce9a90')
    end
  end
end
