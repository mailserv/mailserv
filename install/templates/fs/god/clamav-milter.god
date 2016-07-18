God.watch do |w|
  w.name = "clamav-milter"
  w.interval = 30.seconds # default
  w.start = "rcctl start clamav_milter"
  w.stop = "rcctl stop clamav_milter"
  w.restart = "rcctl restart clamav_milter"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/tmp/clamav-milter.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
