require 'date'

class FeedsController < ApplicationController
  def index
  end

  # GET PubSubHubbub callback after you subscribe 
  def show
    # confirm the subscription
    feed = Feed.find_by_id(params[:id])

    # verify the string parameters
    if params["hub.mode"] == "subscribe" && 
      params["hub.topic"] == feed.url &&
      !params["hub.challenge"].empty?
       
      render status: 200, plain: params["hub.challenge"]

      if res.is_a?(Net::HTTPNoContent)
        # ok subscribed
        feed.status = "subscribed"
        if !params["hub.lease_seconds"].nil? && params["hub.lease_seconds"].to_i > 0
          feed.expiration_date = DateTime.now + Rational(params["hub.lease_seconds"].to_i, 86400)
        end
      else
        # log error (failed to subscribe)
        feed.status = "error"
        feed.error_msg = res.body
      end
      unless feed.save
        # log an error
      end
    else 
      render status: 422, plain: "Invalid parameters"
    end  

  end

  # POST PubSubHubbub - newly pushed entries
  def create
    # process pushed entries
    feed = Feed.find_by_id( params[:id] )
    feed.process_feed_contents( request.raw_post )
  end
end
