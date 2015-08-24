class RemoveUrlsAddSlugToFeedSources < ActiveRecord::Migration
  def change
    remove_column :feed_sources, :urls
    add_column :feed_sources, :slug, :string
  end
end
