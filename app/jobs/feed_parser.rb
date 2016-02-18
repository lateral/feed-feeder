# app/jobs/feed_parser.rb
require 'resque/plugins/lock'

class FeedParser
  extend ResquePostgresDisconnect
  extend Resque::Plugins::Lock
  @queue = :feed_parser

  def self.perform(id, url)
    Feed.find(id).process_feed_contents
  end
end
