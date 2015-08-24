# app/jobs/feed_checker.rb
require 'open-uri'

class FeedChecker

  @queue = :feed_checker

  def self.perform
    # check all the feeds
    Feed.find_each do |feed|
      next if feed.status == "error"

      feed_url = feed.url
      feed_source_id = feed.feed_source_id

      doc = Nokogiri::HTML( open(feed_url) )
      # check if feed supports pubsubhubbub
      if feed.is_pubsubhubbub_supported || (
         !doc.xpath('//feed/link[@rel="hub"]').empty? &&
         !doc.xpath('//feed/link[@rel="self"]').first.attributes["href"].value.empty? &&
         !doc.xpath('//feed/link[@rel="self"]').first.attributes["href"].value.empty? &&
         # check for feed self url
         !doc.xpath('//feed/link[@rel="self"]').empty? &&
         !doc.xpath('//feed/link[@rel="self"]').first.attributes["href"].value.empty? &&
         !doc.xpath('//feed/link[@rel="self"]').first.attributes["href"].value.empty?
         )

        feed.is_pubsubhubbub_supported = true unless feed.is_pubsubhubbub_supported
        if feed.expiration_date.nil? || feed.expiration_date < DateTime.now

          # resubscribe
          webhook_url = FEED_FEEDER_DOMAIN_NAME + "feeds/" + feed.id.to_s

          # get feed self url
          feed_hub_url = doc.xpath('//feed/link[@rel="hub"]').first.attributes["href"].value
          feed_self_url = doc.xpath('//feed/link[@rel="self"]').first.attributes["href"].value

          feed.url = feed_self_url 

          params = {
            'hub.mode' => 'subscribe', 
            'hub.topic' => feed_self_url,
            'hub.callback' => webhook_url,
            'hub.verify' => 'sync'
          }

          resp = Net::HTTP.post_form URI(feed_hub_url), params

          # verify that the subscription call has been accepted
          if resp.status == 202
            feed.status = "subscription_requested"
          else
            # there might be errors
            feed.status = "error"
            feed.error_msg = resp.body
          end
        end
        unless feed.save
          # log an error
        end
      else
        feed.status = "manually_processed" unless feed.status == "manually_processed"
        feed.is_pubsubhubbub_supported = false unless feed.is_pubsubhubbub_supported == false
        unless feed.save
          # log an error
        end
        feed.process_feed_contents( open(feed_url) )
      end
    end
  end
end