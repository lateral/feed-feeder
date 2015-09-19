require 'rails_helper'

RSpec.describe FeedsController, type: :controller do
  it "should render a 200 status and the hub.challenge if the subscription params are valid" do
    feed = FactoryGirl.create(:feed)

    params = {
      "hub.mode" => "subscribe",
      "hub.topic" => feed.url,
      "hub.challenge" => "abc123",
      "hub.lease_seconds" => "86400"
    }
    get :show, id: feed.id

    expect(response).to be_success
    expect(feed.expiration_date).should_not be_nil
  end
  xit "should render a 422 status if the subscription params are invalid" do
  end
end