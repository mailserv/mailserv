God.watch do |w|
  w.name = "clamav-milter"
  w.interval = 30.seconds # default
  w.start = "touch /var/run/clamav-milter.pid; chown _postfix /var/run/clamav-milter.pid; /usr/local/sbin/clamav-milter"
  w.stop = "kill `cat /var/run/clamav-milter.pid`"
  w.restart = "kill `cat /var/run/clamav-milter.pid`; sleep 1; /usr/local/sbin/clamav-milter"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/run/clamav-milter.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
