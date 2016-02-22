class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def keys
    @keys = Key.all
  end

  def feed_sources
    @key = Key.find(params[:key_id])
    @feeds = FeedSource.where(key: @key)
  end

  def feeds
    @key = Key.find(params[:key_id])
    @feed_source = FeedSource.find(params[:feed_source_id])
    @feeds = Feed.where(feed_source: @feed_source)
  end

  def not_found
    fail ActionController::RoutingError.new('Not Found'), 'Not Found'
  end
end
