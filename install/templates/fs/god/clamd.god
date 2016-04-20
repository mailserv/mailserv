# run with:  god -c /etc/god/clamd.god
#

God.watch do |w|
  w.name = "clamd"
  w.interval = 30.seconds # default
  w.start = "rcctl start clamd"
  w.stop = "rcctl stop clamd"
  w.restart = "rcctl restart clamd"
  w.start_grace = 10.seconds
  w.restart_grace = 20.seconds
  w.pid_file = "/tmp/clamd.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 30.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 250.megabytes
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

