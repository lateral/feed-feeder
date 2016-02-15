require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "#create" do
    it 'errors if creating a duplicate' do
      item = FactoryGirl.create :item
      expect {
        FactoryGirl.create :item, feed_source: item.feed_source, guid: item.guid
      }.to raise_exception(ActiveRecord::RecordNotUnique)
    end
  end
end
