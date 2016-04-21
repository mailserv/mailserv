# run with:  god -c /etc/god/admin.god
#

RAILS_ROOT = "/var/mailserv/admin"
RAILS_GEM_VERSION = %x{gem list | grep "rails" | awk '{print $2}'}.sub( /\(/, "").sub( /\)/, "")[1]

%x{
  touch #{RAILS_ROOT}/log/production.log
  chmod 666 #{RAILS_ROOT}/log/production.log
  chown -R _mailserv:_mailserv #{RAILS_ROOT}/log
}

God.watch do |w|
  w.name = "admin"
  w.group = "mailserv"
  w.interval = 30.seconds # default      
  w.start = "/usr/local/bin/mongrel_rails start -c #{RAILS_ROOT} -p 4213 -a 127.0.0.1 -d -e production \
    --user _mailserv --group _mailserv -P #{RAILS_ROOT}/log/mongrel.pid"
  w.stop = "/usr/local/bin/mongrel_rails stop -P #{RAILS_ROOT}/log/mongrel.pid"
  w.restart = "/usr/local/bin/mongrel_rails restart -P #{RAILS_ROOT}/log/mongrel.pid"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = File.join(RAILS_ROOT, "log/mongrel.pid")

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 150.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
