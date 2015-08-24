class RemoveUrlsAddSlugToFeedSources < ActiveRecord::Migration
  def change
    add_column :feed_sources, :slug, :string
  end
end
