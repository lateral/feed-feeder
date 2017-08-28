require 'rails_helper'
RSpec.describe FeedsController, type: :controller do
  before(:each) do
    # Get the feeds contents
    @feed_content = feed_content(:random)

    # Stub head requests so they return 200 and text/html
    stub_request(:head, /.*/).to_return status: 200, headers: { 'Content-Type' => 'text/html; utf-8' }

    # Create the model and set the URL if present in the feed
    @feed = FactoryGirl.create :feed
    @feed.update(url: @feed_content.url) if @feed_content.url.present?
  end

  describe 'FeedController GET method' do
    it '404s when feed not found' do
      expect { get :webhook_subscribe, params: { id: 9001 } }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should render a 200 status and the hub.challenge if the subscription params are valid' do
      params = {
        'id' => @feed.id,
        'hub.mode' => 'subscribe',
        'hub.topic' => @feed.url,
        'hub.challenge' => 'abc123',
        'hub.lease_seconds' => '86400'
      }
      get :webhook_subscribe, params: params
      expect(response.status).to eq(200)
      expect(response.body).to eq('abc123')
      @feed.reload
      expect(@feed.expiration_date).to_not be_nil
    end

    it 'should render a 422 status if the subscription params are invalid' do
      params = {
        'id' => @feed.id,
        'hub.mode' => 'cause_a_422',
        'hub.topic' => 'foo'
      }
      get :webhook_subscribe, params: params
      expect(response.status).to eq(422)
    end
  end

  describe 'FeedController POST method' do
    it '404s when feed not found' do
      expect { post :webhook_update, params: { id: 9001 } }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should process contents of feed to database' do
      with_resque do
        stub_request(:any, @feed.url).to_return body: @feed_content.content
        stub_feed_run_python_method

        post :webhook_update, params: { id: @feed.id }
        items = @feed.feed_source.items
        expect(items.size).to be > 0
        expect(items.first.title.class).to eq(String)
      end
    end
  end
end
