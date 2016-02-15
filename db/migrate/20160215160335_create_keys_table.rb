class CreateKeysTable < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.string :key
      t.string :endpoint
      t.string :purpose
    end

    create_table :feed_sources_keys, id: false do |t|
      t.belongs_to :feed_source, index: true
      t.belongs_to :key, index: true
    end
  end
end
