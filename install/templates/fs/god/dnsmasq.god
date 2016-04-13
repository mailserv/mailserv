God.watch do |w|
  w.name = "dnsmasq"
  w.group = "mailserv"
  w.interval = 30.seconds # default
  w.start = "rcctl start dnsmasq"
  w.stop = "rcctl stop dnsmasq"
  w.restart = "rcctl restart dnsmasq"
  w.start_grace = 10.seconds
  w.restart_grace = 15.seconds
  w.pid_file = "/var/run/dnsmasq.pid"

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end


