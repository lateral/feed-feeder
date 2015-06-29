# http://robots.thoughtbot.com/process-jobs-inline-when-running-acceptance-tests
module BackgroundJobs
  def run_background_jobs_immediately
    inline = Resque.inline
    Resque.inline = true
    yield
    Resque.inline = inline
  end
end
RSpec.configure do |config|
  config.around(:each, type: :feature) do |example|
    run_background_jobs_immediately do
      example.run
    end
  end
  config.include BackgroundJobs
end
