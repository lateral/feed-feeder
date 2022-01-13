require 'resque/failure/multiple'
require 'resque/failure/redis'


if Rails.env.production?
  uri = URI.parse(ENV["REDIS_URL"])
else
  uri = URI.parse("redis://localhost:6379")
end
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Resque.redis.namespace = "resque:#{Rails.application.class.module_parent.name}"

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

# The schedule doesn't need to be stored in a YAML, it just needs to
# be a hash.  YAML is usually the easiest.
Resque.schedule = YAML.load_file(Rails.root.join('config', 'resque_scheduler.yml'))
