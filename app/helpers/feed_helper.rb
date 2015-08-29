module FeedHelper
  def get_feed
    return Feed.find_by_id(params[:id])
  end
end