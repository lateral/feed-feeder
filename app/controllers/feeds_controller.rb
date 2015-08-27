require 'date'

class FeedsController < ApplicationController
  # GET PubSubHubbub callback after you subscribe 
  def show
    # confirm the subscription
    feed = Feed.find_by_id(params[:id])

    # verify the string parameters
    if params["hub.mode"] == "subscribe" && 
      params["hub.topic"] == feed.url &&
      !params["hub.challenge"].empty?

      render status: 200, plain: params["hub.challenge"]
    else 
      render status: 422, plain: "Invalid parameters"
    end  
  end

  # POST PubSubHubbub - newly pushed entries
  # also used for subscription confirmation
  def create
    if response.response_code == 204
      # ok subscribed
      feed.status = "subscribed"
      if !params["hub.lease_seconds"].nil? && params["hub.lease_seconds"].to_i > 0
        feed.expiration_date = DateTime.now + Rational(params["hub.lease_seconds"].to_i, 86400)
        unless feed.save
          # log error
        end
      end
    else
      # process pushed entries
      feed = Feed.find_by_id( params[:id] )
      # differentiate between Standard notifications and fat pings
      if requests.body.nil?
        # Standard Notification (must be processed manually)
        feed.process_feed_contents( open(feed.url) )
      else
        # check if is pubsubhubbub's empty confirmation response

        # fat ping
        feed.process_feed_contents( request.raw_post )
      end
    end
  end
end
