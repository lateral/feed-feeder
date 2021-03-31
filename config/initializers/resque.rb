Resque.redis = "127.0.0.1:6379"
Resque.redis.namespace = "resque:#{Rails.application.class.module_parent.name}"

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

# The schedule doesn't need to be stored in a YAML, it just needs to
# be a hash.  YAML is usually the easiest.
Resque.schedule = YAML.load_file(Rails.root.join('config', 'resque_scheduler.yml'))
