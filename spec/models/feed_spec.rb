require 'rails_helper'

RSpec.describe Feed, type: :model do
  describe '#process_feed_contents' do
    before(:each) do
      Feed.destroy_all

      # Stub head requests so they return 200 and text/html
      stub_request(:head, /.*/).to_return status: 200, headers: { 'Content-Type' => 'text/html; utf-8' }

      # Get the feeds contents and create the model
      @feed_content = feed_content(:random)
      @feed = FactoryGirl.create :feed
      @feed.update(url: @feed_content.url) if @feed_content.url.present?
    end

    it 'inserts the correct fields' do
      stub_request(:any, @feed.url).to_return body: @feed_content.content
      stub_feed_run_python_method
      @feed.process_feed_contents
      @feed.feed_source.items.each do |item|
        expect(item.key_id).to eq(@feed.feed_source.key.id)
        expect(item.feed_id).to eq(@feed.id)
        expect(item.body).to_not eq(nil)
      end
    end

    it 'handles duplicates' do
      # Use feed content with duplicates
      stub_request(:any, @feed.url).to_return body: feed_content(:with_duplicates).content
      stub_feed_run_python_method
      @feed.process_feed_contents
      @feed.process_feed_contents
      expect(@feed.feed_source.items.count).to eq(1)
    end

    it 'handles XML error' do
      stub_request(:any, @feed.url).to_return body: 'content'
      stub_feed_run_python_method
      @feed.process_feed_contents
      expect(@feed.error_msg).to eq('No valid parser for XML.')
    end

    it 'prepends the feed domain if the URL starts with /' do
      # Use feed content that doesn't have relative URLs
      stub_request(:any, @feed.url).to_return body: feed_content(:with_relative_urls).content
      stub_feed_run_python_method
      @feed.process_feed_contents
      @feed.feed_source.items.each do |item|
        expect(item.url).to_not start_with('/')
      end
    end

    it 'adds items with from_initial_sync=true if no items exist' do
      stub_request(:any, @feed.url).to_return body: @feed_content.content
      stub_feed_run_python_method
      @feed.process_feed_contents
      @feed.feed_source.items.each do |item|
        expect(item.from_initial_sync).to eq(true)
      end
    end

    it 'adds items with from_initial_sync=false if items already exist' do
      FactoryGirl.create_list :item, 10, feed: @feed, feed_source: @feed.feed_source, from_initial_sync: true
      stub_request(:any, @feed.url).to_return body: @feed_content.content
      stub_feed_run_python_method
      @feed.process_feed_contents
      count_minus_initial = @feed.feed_source.items.count - 10
      count_from_intial_sync_false = @feed.feed_source.items.where(from_initial_sync: false).count
      expect(count_from_intial_sync_false).to eq(count_minus_initial)
    end

    it 'adds items with from_initial_sync=false if is a pubsubhubbub feed' do
      @feed.update(is_pubsubhubbub_supported: true)
      stub_request(:any, @feed.url).to_return body: @feed_content.content
      stub_feed_run_python_method
      @feed.process_feed_contents
      @feed.feed_source.items.each do |item|
        expect(item.from_initial_sync).to eq(false)
      end
    end

    it 'skips items that return a status other than 200' do
      stub_request(:head, /.*/).to_return status: 400, headers: { 'Content-Type' => 'text/html; utf-8' }
      stub_request(:any, @feed.url).to_return body: @feed_content.content
      stub_feed_run_python_method
      @feed.process_feed_contents
      expect(@feed.feed_source.items.count).to eq(0)
    end

    it 'skips items that return a content type other than text/html*' do
      stub_request(:head, /.*/).to_return status: 200, headers: { 'Content-Type' => 'text/plain' }
      stub_request(:any, @feed.url).to_return body: @feed_content.content
      stub_feed_run_python_method
      @feed.process_feed_contents
      expect(@feed.feed_source.items.count).to eq(0)
    end
  end

  describe '#add_feed_item' do
    before(:each) do
      Feed.destroy_all
      stub_request(:head, /.*/).to_return status: 200, headers: { 'Content-Type' => 'text/html; utf-8' }
      @feed = FactoryGirl.create :feed
    end

    it 'saves a single author' do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'a name', body: '', image: '', summary: '', title: '')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      expect(item.authors.first.name).to eq('a name')
      expect(item.authors.first.hash_id).to eq('e31052641f40d49d87c369b4b8655403')
    end

    it 'saves the summary if the body is empty' do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url, summary: 'testing')
      stub_feed_run_python_method(author: 'a name', body: '', image: '', summary: '', title: '')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      expect(item.body).to eq('testing')
      expect(item.authors.first.name).to eq('a name')
      expect(item.authors.first.hash_id).to eq('e31052641f40d49d87c369b4b8655403')
    end

    it 'strips whitespace from authors' do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'a name  ', body: '', image: '', summary: '', title: '')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      expect(item.authors.first.name).to eq('a name')
      expect(item.authors.first.hash_id).to eq('e31052641f40d49d87c369b4b8655403')
    end

    it 'strips special characters from authors' do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'M. Novakovic', body: '', image: '', summary: '', title: '')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      expect(item.authors.first.name).to eq('M. Novakovic')
      expect(item.authors.first.hash_id).to eq('20d3a0fe0c6a52998f64d7dbfe6ea70f')
    end

    it 'ignores case from authors' do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'm novakovic', body: '', image: '', summary: '', title: '')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      expect(item.authors.first.hash_id).to eq('20d3a0fe0c6a52998f64d7dbfe6ea70f')
    end

    it "ignores author from the AUTHORS_BLACKLIST['hash_ids']" do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'Great Speculations', body: '', image: '', summary: '', title: '')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      expect(item.authors.first).to eq(nil)
    end

    it "ignores author from the AUTHORS_BLACKLIST['name_start_match']" do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'http test this', body: '', image: '', summary: '', title: '')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      expect(item.authors.first).to eq(nil)
    end

    it "doesn't match if no space with AUTHORS_BLACKLIST['name_start_match']" do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'httptest this', body: '', image: '', summary: '', title: '')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      expect(item.authors.first.name).to eq('httptest this')
    end

    it 'ignores author from the AUTHORS_BLACKLIST' do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'Great Speculations', body: '', image: '', summary: '', title: '')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      expect(item.authors.first).to eq(nil)
    end

    it 'saves multiple authors' do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'a name, a second name')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      expect(item.authors.first.name).to eq('a name')
      expect(item.authors.first.hash_id).to eq('e31052641f40d49d87c369b4b8655403')
      expect(item.authors.second.name).to eq('a second name')
      expect(item.authors.second.hash_id).to eq('f79d1b8f3a2a7b4ed82b34cd5b6cc301')
    end

    it 'reuses authors' do
      entry = OpenStruct.new(entry_id: '100', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'a name')
      @feed.add_feed_item entry

      item = Item.find_by(guid: entry.entry_id)
      author = item.authors.first
      expect(author.name).to eq('a name')
      expect(author.hash_id).to eq('e31052641f40d49d87c369b4b8655403')

      entry = OpenStruct.new(entry_id: '101', published: 'date', url: @feed.url)
      stub_feed_run_python_method(author: 'a name')
      @feed.add_feed_item entry
      item = Item.find_by(guid: entry.entry_id)
      expect(item.authors.first.id).to eq(author.id)
    end
  end

  Dir.glob(Rails.root.join('spec/fixtures/feeds/*.xml')).sort.each do |feed_path|
    feed_filename = File.basename(feed_path, '.xml')
    describe "#process_feed_contents with feed #{feed_filename}.xml" do
      before(:each) do
        Feed.destroy_all

        # Stub head requests so they return 200 and text/html
        stub_request(:head, /.*/).to_return status: 200, headers: { 'Content-Type' => 'text/html; utf-8' }

        # Get the feeds contents and create the model
        @feed_content = feed_content(feed_filename)
        @feed = FactoryGirl.create :feed
        @feed.update(url: @feed_content.url) if @feed_content.url.present?
      end

      it 'adds feed items' do
        stub_request(:any, @feed.url).to_return body: @feed_content.content
        stub_feed_run_python_method
        @feed.process_feed_contents
        expect(@feed.feed_source.items.count).to_not eq(0)
      end
    end
  end
end
