# app/jobs/feed_checker.rb
class FeedChecker
  extend ResquePostgresDisconnect
  include Resque::Plugins::UniqueJob
  @queue = :feed_checker

  def self.perform
    # check all the feeds
    Feed.find_each do |feed|
      next if feed.status == 'error'

      # Get the feeds content
      begin
        feed_content = RestClient.get(feed.url).body

      # Skip if there is a 404
      rescue RestClient::ResourceNotFound
        feed.status = 'error'
        feed.error_msg = 'Feed returned 404 on initial fetch'
        feed.save
        next
      end

      # Detect the hub and rel="self" nodes
      doc = Nokogiri::XML feed_content
      hub = doc.xpath("//*[@rel='hub']/@href")
      rel_self = doc.xpath("//*[@rel='self']/@href")

      # Check if feed was previously detected as pubsubhubbub or if it supports it
      if feed.is_pubsubhubbub_supported ||
         (feed.status.present? && feed.status != 'manually_processed') ||
         (hub[0].present? && hub[0].value.present? && rel_self[0].present? && rel_self[0].value.present?)

        # Update the feeds PubSubHubbub status
        feed.is_pubsubhubbub_supported = true unless feed.is_pubsubhubbub_supported

        # Update feed hub if needed
        if feed.expiration_date.nil? || feed.expiration_date < DateTime.now

          # Set the feed URL to the rel="self" href
          feed.url = rel_self[0].value

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
    end
  end
end
