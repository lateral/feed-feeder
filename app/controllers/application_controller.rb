class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def administration
    @feeds = FeedSource.all
  end

  def administration_feed
    @feed_source = FeedSource.find(params[:id])
    @feeds = Feed.where(feed_source: @feed_source)
  end

  def not_found
    fail ActionController::RoutingError.new('Not Found'), 'Not Found'
  end
end
