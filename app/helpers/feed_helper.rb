module FeedHelper

  def process_feed_contents( html_contents, feed_source_id )
  
    rss = SimpleRSS.parse html_contents

    # check each entry
    rss.entries.each do |entry|
      entry_url = entry.link
      entry_hash = run_python('recommend-by-url', entry_url )

      item = Items.new
      feed.feed_source_id = feed_source_id
      item.url = entry_url
      item.title = entry_hash[:title]
      item.summary = entry_hash[:summary]
      item.author = entry_hash[:author]
      item.image = entry_hash[:image]
      item.published = entry_hash[:published]

      # Not accounted for:
      #   guid
      #   sent_to_api
      #   rejected_from_api
      #   image_thumbnail
      #   api_response
      
      unless item.save
        # raise an error
      end
      # manage rate limiting
      sleep 5
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