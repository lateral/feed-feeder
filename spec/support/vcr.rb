VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_hosts '127.0.0.1'
  # c.filter_sensitive_data('<LATERAL_NEWS_KEY>') { ENV['LATERAL_NEWS_KEY'] }
end
