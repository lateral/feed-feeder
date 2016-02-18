# apps/models/feed.rb
class Feed < ActiveRecord::Base
  has_and_belongs_to_many :keys
  belongs_to :feed_source
  has_many :items

  enum status: [:unsubscribed, :manually_processed, :subscription_requested, :subscribed, :error]

  def process_feed_contents
    # If pubsubhubbub isn't supported and there are no existing items then it is an initial sync.
    # This signals to newsbot not to recommend from these items as they could be old.
    initial_sync = (is_pubsubhubbub_supported != true && items.count == 0)

    begin
      feed = Feedjira::Feed.fetch_and_parse url
    rescue Feedjira::NoParserAvailable => e
      self.status = 'error'
      self.error_msg = e.message
      save
      return
    end

    # check each url
    feed.entries.each do |entry|
      # check if the link is new or has already been processed
      next if Item.find_by(feed_source: feed_source, guid: entry.entry_id)

      # Otherwise add it
      add_feed_item(entry, initial_sync)
    end
  end

  def add_feed_item(entry, initial_sync = false)
    fix_relative_path(entry) if entry.url.start_with?('/')
    entry_hash = run_python('recommend-by-url.py', entry.url)
    item_hash = {
      author: entry_hash[:author],
      body: entry_hash[:body],
      feed_id: self.id,
      feed_source_id: self.feed_source_id,
      guid: entry.entry_id,
      image: entry_hash[:image],
      published: entry.published,
      summary: entry_hash[:summary],
      title: entry_hash[:title],
      url: entry.url,
      from_initial_sync: initial_sync
    }

    # Save item, log if fails
    item = Item.new(item_hash)
    begin
      logger.error "ITEM SAVE TO DB ERROR: #{item.inspect}" unless item.save
    rescue ActiveRecord::RecordNotUnique
      logger.error "Tried to add duplicate: #{item.guid}"
    end
  end

  private

  # Takes the feed URL and extracts the scheme and host, then prepends the
  # assembled elements before the entry path. It's by no means fool proof but
  # will work in some cases (e.g. The Guardian). If feed url is different
  # domain (e.g. feeds.blah.com) then this method will fail
  def fix_relative_path(entry)
    feed_url = Addressable::URI.parse(url)
    entry.url = feed_url.scheme + '://' + feed_url.host + entry.url
  end

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
