God.watch do |w|
  w.name = "freshclam"
  w.interval = 30.seconds # default
  w.start = "rcctl start freshclam"
  w.stop = "rcctl stop freshclam"
  w.restart = "rcctl restart freshclam"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/tmp/freshclam.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
