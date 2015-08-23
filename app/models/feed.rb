# apps/models/feed.rb
require 'open-uri'
class Feed < ActiveRecord::Base
  belongs_to :feed_source

  enum status: [:unsubscribed, :manually_processed, :subscription_requested, :subscribed, :error]

  def process_feed_contents( feed_url )
  
    rss = SimpleRSS.parse open(feed_url)

    # check each entry
    rss.entries.each do |entry|

      add_feed_item(entry.link)

      # manage rate limiting
      sleep 5
    end

  end

  def add_feed_item(entry_url)
    entry_hash = run_python('recommend-by-url.py', entry_url)
    item_hash = {
      feed_source_id: self.feed_source_id,
      url: entry_url,
      title: entry_hash[:title],
      summary: entry_hash[:summary],
      author: entry_hash[:author],
      image: entry_hash[:image],
      published: entry_hash[:published]
    }
    item = Item.first_or_create(item_hash)
    unless item.save
      # raise an error
    end
  end

  private

  def run_python(script, arg)
    script = Rails.root.join('lib', script)
    output = `PYTHONIOENCODING=utf-8 python #{script} '#{arg}' 2>&1`
    JSON.parse(output, symbolize_names: true)
  rescue JSON::ParserError => e
    if Rails.env.production?
      error! 'Error getting URL contents', 500
    else
      error! e.message, 500
    end
  end
end