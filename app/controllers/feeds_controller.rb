require 'date'
class FeedsController < ApplicationController
  before_filter :set_feed
  skip_before_action :verify_authenticity_token

  # GET PubSubHubbub callback after you subscribe
  def webhook_subscribe
    # verify the string parameters
    if params['hub.mode'] == 'subscribe' &&
       params['hub.topic'] == @feed.url &&
       params['hub.challenge'].present?

      @feed.status = 'subscription_requested' # 17 mins
      if params['hub.lease_seconds'].present? && params['hub.lease_seconds'].to_i > 0
        @feed.expiration_date = DateTime.now + Rational(params['hub.lease_seconds'].to_i, 86_400)
        unless @feed.save
          # log error
          logger.error "FEED SAVE TO DB ERROR:#{@feed.inspect}"
        end
      end

      render status: 200, plain: params['hub.challenge']
    else
      render status: 422, plain: 'Invalid parameters'
    end
  end

  # POST PubSubHubbub - newly pushed entries
  # also used for subscription confirmation
  def webhook_update
    @feed = Feed.find(params[:id])
    Resque.enqueue(FeedParser, @feed.id, @feed.url)
    render status: 200, plain: ''
  end

  private

  def set_feed
    @feed = Feed.find(params[:id])
  end
end
