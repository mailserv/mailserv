# run with:  god -c /etc/god/mysql.god
#

God.watch do |w|
  w.name = "mysql"
  w.interval = 30.seconds # default
  w.start = "rcctl start mysqld"
  w.stop = "rcctl stop mysqld"
  w.restart = "rcctl restart mysqld"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/run/mysql/mysql.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 30.seconds
      c.running = false
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
