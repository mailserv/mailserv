
God.watch do |w|
  w.name = "spamassassin"
  w.group = "mailserv"
  w.interval = 30.seconds # default
  w.start = "rcctl start spamassassin"
  w.stop = "rcctl stop spamassassin"
  w.restart = "rcctl restart spamassassin"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/run/spamassassin.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
