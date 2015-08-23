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
       
      uri = URI(feed.url)
      req = Net::HTTP::Post.new(uri)
      req.content_type = 'text/plain'
      req.body = params["hub.challenge"]
      # "you will need to reply with 200 OK" <- Not sure how to do this
      # From another webpage: To confirm, the webhook needs to serve a 200 status 
      # and output the hub.challenge in the response body.
      
      # req.code = 200 ???
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end

      if res.is_a?(Net::HTTPNoContent)
        # ok subscribed
        feed.status = "subscribed"
        if !params["hub.lease_seconds"].nil? && params["hub.lease_seconds"].to_i > 0
          feed.expiration_date = DateTime.now + Rational(params["hub.lease_seconds"].to_i, 86400)
        end
        unless feed.save
          # report error
        end

      else
        # log error (failed to subscribe)
        feed.status = "error"
        feed.error_msg = res.body
      end
    end  

  end

  # POST PubSubHubbub - newly pushed entries
  def create
    # process pushed entries
    feed = Feed.find_by_id( params[:id] )
    feed.process_feed_contents( request.raw_post )
  end
end
