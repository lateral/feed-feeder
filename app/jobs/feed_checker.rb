# app/jobs/feed_checker.rb
require 'open-uri'

class FeedChecker
  @queue = :feed_checker

  def self.perform
    # check all the feeds
    Feed.find_each do |feed|
      next if feed.status == 'error'

      feed_url = feed.url
      # feed_source_id = feed.feed_source_id

      # Get the feeds content
      doc = Nokogiri::HTML(open(feed_url))

      # Check if feed was previously detected as pubsubhubbub
      if feed.status != 'manually_processed' || feed.is_pubsubhubbub_supported || (
         # Otherwise check for required hub and self fields in the feed
         !doc.xpath('//feed/link[@rel="hub"]').empty? &&
         !doc.xpath('//feed/link[@rel="hub"]').first.attributes['href'].value.empty? &&
         !doc.xpath('//feed/link[@rel="self"]').empty? &&
         !doc.xpath('//feed/link[@rel="self"]').first.attributes['href'].value.empty?)

        # Update the feeds PubSubHubbub status
        feed.is_pubsubhubbub_supported = true unless feed.is_pubsubhubbub_supported

        # Update feed hub if needed
        if feed.expiration_date.nil? || feed.expiration_date < DateTime.now

          webhook_url = ENV['FEED_FEEDER_DOMAIN'] + 'feeds/' + feed.id.to_s

          # get feed self url
          feed_hub_url = doc.xpath('//feed/link[@rel="hub"]').first.attributes['href'].value
          feed_self_url = doc.xpath('//feed/link[@rel="self"]').first.attributes['href'].value

          feed.url = feed_self_url

          params = {
            'hub.mode' => 'subscribe',
            'hub.topic' => feed_self_url,
            'hub.callback' => webhook_url,
            'hub.verify' => 'sync'
          }

          # verify that the subscription call has been accepted
          begin
            RestClient.post feed_hub_url, params

          # there might be errors
          rescue RestClient::UnprocessableEntity => e
            feed.status = 'error'
            feed.error_msg = e.response
            feed.save
          end

          # No exceptions, was OK
          feed.status = 'subscribed'
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
        feed.process_feed_contents(open(feed_url))
      end
    end
  end
end
