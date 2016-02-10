require 'rails_helper'

RSpec.describe FeedChecker do
  describe '#perform' do
    before(:each) do
      Feed.destroy_all
      @feed = FactoryGirl.create(:feed)
      # stub_request(:any, 'http://pubsubhubbub.superfeedr.com/').with(body: 'err', status: 422)
    end

    it 'adds a feed with a hub' do
      stub_request(:any, @feed.url).to_return body: feed_content(:with_hub)
      stub_request(:any, 'http://pubsubhubbub.superfeedr.com/')

      with_resque do
        Resque.enqueue(FeedChecker)
        expect(a_request(:get, @feed.url)).to have_been_made
        @feed.reload
        expect(@feed.status).to eq('subscribed')
        expect(@feed.error_msg).to eq(nil)
      end
    end

    it 'catches error from a feed with a hub' do
      stub_request(:any, @feed.url).with body: feed_content(:with_hub)
      stub_request(:any, 'http://pubsubhubbub.superfeedr.com/').to_return(body: 'err', status: 422)

      with_resque do
        Resque.enqueue(FeedChecker)
        expect(a_request(:get, @feed.url)).to have_been_made
        @feed.reload
        expect(@feed.status).to eq('subscribed')
        expect(@feed.error_msg).to eq('err')
      end
    end
  end
end
