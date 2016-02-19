# http://git.io/bvIb
rails_env   = ENV['RAILS_ENV']  || 'production'
rails_root  = ENV['RAILS_ROOT'] || '/home/ubuntu/app'

God.watch do |w|
  pid_file   = "#{rails_root}/tmp/pids/resque-scheduler.pid"
  w.dir      = "#{rails_root}"
  w.name     = 'resque-scheduler'
  w.group    = 'resque'
  w.interval = 30.seconds
  w.env      = { 'RAILS_ENV' => rails_env, 'PIDFILE' => pid_file }
  w.start    = "rake -f #{rails_root}/Rakefile environment resque:scheduler"
  w.stop     = "kill -QUIT `cat #{pid_file}`"
  w.log      = "#{rails_root}/log/resque-scheduler.log"
  w.err_log  = "#{rails_root}/log/resque-scheduler-error.log"
  w.pid_file = pid_file
  # w.uid = 'webapp'
  # w.gid = 'webapp'

  # determine the state on startup
  w.transition(:init, true => :up, false => :start) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 350.megabytes
      c.times = 2
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end
