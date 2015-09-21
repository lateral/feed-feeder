require 'date'

class FeedsController < ApplicationController

  include FeedHelper

  # GET PubSubHubbub callback after you subscribe
  def show
    # confirm the subscription
    feed = get_feed

    # verify the string parameters
    if params["hub.mode"] == "subscribe" &&
      params["hub.topic"] == feed.url &&
      !params["hub.challenge"].empty?

      feed.status = "subscription_requested" # 17 mins
      if !params["hub.lease_seconds"].nil? && params["hub.lease_seconds"].to_i > 0
        feed.expiration_date = DateTime.now + Rational(params["hub.lease_seconds"].to_i, 86400)
        unless feed.save
          # log error
          logger.error "FEED SAVE TO DB ERROR:#{feed.inspect}"
        end
      end

      render status: 200, plain: params["hub.challenge"]
    else
      render status: 422, plain: "Invalid parameters"
    end
  end

  # POST PubSubHubbub - newly pushed entries
  # also used for subscription confirmation
  def create
    # process pushed entries
    feed = get_feed
    # differentiate between Standard notifications and fat pings
    if requests.body.nil?
      # Standard Notification (must be processed manually)
      feed.process_feed_contents( open(feed.url) )
    else
      # fat ping
      feed.process_feed_contents( request.raw_post )
    end
  end
end
