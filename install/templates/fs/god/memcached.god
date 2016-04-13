God.watch do |w|
  w.name = "memcached"
  w.interval = 30.seconds
  w.pid_file = "/var/run/memcached/memcached.pid"
  w.start = "rcctl start memcached"
  w.stop = "rcctl stop memcached"
  w.restart = "rcctl restart memcached"
  w.start_grace = 20.seconds
  w.restart_grace = 10.seconds

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
