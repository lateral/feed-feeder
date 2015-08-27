# apps/models/feed.rb
require 'open-uri'
class Feed < ActiveRecord::Base
  belongs_to :feed_source

  enum status: [:unsubscribed, :manually_processed, :subscription_requested, :subscribed, :error]

  def process_feed_contents( html_contents )
  
    urls = SimpleRSS.parse( html_contents ).entries.map{|e| e.link }

    # check each url
    urls.each do |url|

      # check if the link is new or has already been processed
      if Item.find_by_url(url).nil?
        add_feed_item(url) 
        # manage rate limiting
        sleep 5
      end
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
    item = Item.new(item_hash)
    unless item.save
      # raise an error
    end
  end

  private

  def run_python(script, arg)
    begin
      script = Rails.root.join('lib', script)
      output = `PYTHONIOENCODING=utf-8 python #{script} '#{arg}' 2>&1`
      JSON.parse(output, symbolize_names: true)
    rescue
      # return empty metadata hash
      {}
    end
  end
end