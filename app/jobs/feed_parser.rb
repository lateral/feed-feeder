# app/jobs/feed_parser.rb
class FeedParser
  extend ResquePostgresDisconnect
  include Resque::Plugins::UniqueJob
  @queue = :feed_parser

  def self.perform(id, url)
    Feed.find(id).process_feed_contents
  end
end
