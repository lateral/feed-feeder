# app/jobs/feed_checker.rb
require 'resque/plugins/lock'

class FeedChecker
  extend ResquePostgresDisconnect
  extend Resque::Plugins::Lock
  @queue = :feed_checker

  def self.perform
    # check all the feeds
    Feed.find_each do |feed|
      begin
        # Get the feeds content
        begin
          feed_content = RestClient::Request.execute(method: :get, url: feed.url, verify_ssl: false, user_agent: UA).body

        # Skip if there is a 404
        rescue RestClient::Exception => e
          feed.error_msg = "Feed returned #{e.http_code} on initial fetch"
          feed.save
          next
        rescue SocketError
          feed.error_msg = 'Feed triggered SocketError on initial fetch'
          feed.save
          next
        end

        # Detect the hub and rel="self" nodes
        doc = Nokogiri::XML feed_content
        hub = doc.xpath("//*[@rel='hub']/@href")
        rel_self = doc.xpath("//*[@rel='self']/@href")

        # Check if feed was previously detected as pubsubhubbub or if it supports it
        if feed.is_pubsubhubbub_supported ||
           (hub[0].present? && hub[0].value.present? && rel_self[0].present? && rel_self[0].value.present?)

          # Update the feeds PubSubHubbub status
          feed.is_pubsubhubbub_supported = true unless feed.is_pubsubhubbub_supported

          # Update feed hub if needed
          if feed.expiration_date.nil? || feed.expiration_date < DateTime.now

            # Set the feed URL to the rel="self" href
            begin
              feed.url = rel_self[0].value
            rescue NoMethodError
              feed.status = 'manually_processed'
              feed.is_pubsubhubbub_supported = false
              next
            end

            params = {
              'hub.mode' => 'subscribe',
              'hub.topic' => feed.url,
              'hub.callback' => ENV['FEED_FEEDER_DOMAIN'] + 'feeds/' + feed.id.to_s,
              'hub.verify' => 'sync'
            }

            # verify that the subscription call has been accepted
            begin
              RestClient.post hub[0].value, params
              feed.status = 'subscribed'

            # there might be errors
            rescue RestClient::Exception => e
              feed.status = 'error'
              feed.error_msg = e.response

            # If the feed is malformed and for some reason doesn't have the hub
            rescue NoMethodError => e
              feed.status = 'manually_processed'
              feed.is_pubsubhubbub_supported = false
            end
          end

          # Save the feed, log error if there is one
          logger.error "FEED SAVE TO DB ERROR:#{feed.inspect}" unless feed.save

        # PubSubHubbub not supported so process manually
        else
          feed.status = 'manually_processed' unless feed.status == 'manually_processed'
          feed.is_pubsubhubbub_supported = false unless feed.is_pubsubhubbub_supported == false

          # Save the feed, log error if there is one
          logger.error "FEED SAVE TO DB ERROR:#{feed.inspect}" unless feed.save

          # Process the feeds contents
          Resque.enqueue(FeedParser, feed.id, feed.url)
        end
      rescue StandardError => e
        # ap e.message
        # ap e.backtrace
        feed.status = 'error'
        feed.error_msg = "StandardError rescued #{e.message}"
        feed.save
        next
      end
    end
  end
end
