require 'rails_helper'
RSpec.describe FeedsController, type: :controller do

  before (:each) do
    feed_source = FactoryGirl.create(:feed_source)
    @feed = FactoryGirl.create(:feed)
    @feed.feed_source_id = feed_source.id
    @feed.save
  end
  describe "FeedController GET method" do
    it "should render a 200 status and the hub.challenge if the subscription params are valid" do
      params = {
        "id" => @feed.id,
        "hub.mode" => "subscribe",
        "hub.topic" => @feed.url,
        "hub.challenge" => "abc123",
        "hub.lease_seconds" => "86400"
      }
      get :show, params
      expect(response.status).to eq(200)
      expect(response.body).to eq("abc123")
      f = Feed.find(@feed.id)
      expect(f.expiration_date).to_not be_nil
    end
    it "should render a 422 status if the subscription params are invalid" do
      params = {
        "id" => @feed.id,
        "hub.mode" => "cause_a_422",
        "hub.topic" => "foo"
      }
      get :show, params
      expect(response.status).to eq(422)
    end
  end
  describe "FeedController POST method" do
    VCR.use_cassette('feed_controller_post') do
      it "should process contents of feed to database" do
        post :create, { id: @feed.id }
        fs = FeedSource.find(@feed.feed_source_id)
        items = fs.items
        expect(items.size).to be > 0
        expect(items.first.title.class).to eq(String)
      end
    end
  end
end