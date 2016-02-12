require 'rails_helper'

RSpec.describe FeedChecker do
  # Loop through every feed with a hub
  Dir.glob(Rails.root.join('spec/fixtures/feeds/*_hub.xml')).sort.each do |feed_path|
    feed_filename = File.basename(feed_path, '.xml')

    describe "Feed with hub: #{feed_filename}.xml" do
      before(:each) do
        Feed.destroy_all
        # Get the feeds contents
        @feed_content = IO.read(feed_path)

        # Parse the feed to get the hub
        feed = Feedjira::Feed.parse @feed_content
        @hub = feed.hubs.first

        # Create the model and set the URL if present in the feed
        @feed = FactoryGirl.create :feed
        @feed.update(url: feed.url) if feed.url.present?
      end

      it 'successfully adds' do
        # Stub feed and hub requests
        stub_request(:any, @feed.url).to_return body: @feed_content
        stub_request(:any, @hub)

        # Run the job
        with_resque do
          Resque.enqueue(FeedChecker)

          # Check that the feed and the hub are requested
          expect(a_request(:get, @feed.url)).to have_been_made
          params = {
            'hub.mode' => 'subscribe',
            'hub.topic' => @feed.url,
            'hub.callback' => ENV['FEED_FEEDER_DOMAIN'] + 'feeds/' + @feed.id.to_s,
            'hub.verify' => 'sync'
          }
          expect(a_request(:post, @hub).with(body: params)).to have_been_made

          # Feed model should be updated
          @feed.reload
          expect(@feed.status).to eq('subscribed')
          expect(@feed.error_msg).to eq(nil)
        end
      end

      it 'catches subscription request error' do
        # Stub feed and hub requests - hub now errors
        stub_request(:any, @feed.url).to_return body: @feed_content
        stub_request(:any, @hub).to_return body: 'err', status: 422

        # Run the job
        with_resque do
          Resque.enqueue(FeedChecker)

          # Check that the feed and the hub are requested
          expect(a_request(:get, @feed.url)).to have_been_made
          expect(a_request(:post, @hub)).to have_been_made

          # Feed model should be updated
          @feed.reload
          expect(@feed.status).to eq('error')
          expect(@feed.error_msg).to eq('err')
        end
      end
    end
  end

  Dir.glob(Rails.root.join('spec/fixtures/feeds/*_nohub.xml')).sort.each do |feed_path|
    feed_filename = File.basename(feed_path, '.xml')

    describe "Feed without hub: #{feed_filename}.xml" do
      before(:each) do
        Feed.destroy_all
        @feed_content = IO.read(feed_path)
        @feed = FactoryGirl.create :feed
      end

      it 'successfully adds' do
        stub_request(:any, @feed.url).to_return body: @feed_content
        doc = {
          author: Faker::Name.name,
          body: Faker::Lorem.paragraph(3),
          image: Faker::Internet.url,
          keywords: Faker::Lorem.words(5),
          published: '',
          summary: Faker::Lorem.paragraph,
          title: Faker::Lorem.sentence,
          videos: [Faker::Internet.url]
        }
        allow_any_instance_of(Feed).to receive(:run_python).and_return(doc)

        with_resque do
          Resque.enqueue(FeedChecker)
          @feed.reload
          expect(@feed.status).to eq('manually_processed')
          expect(@feed.error_msg).to eq(nil)
          expect(@feed.feed_source.items.count).to_not eq(0)
        end
      end
    end
  end
end
