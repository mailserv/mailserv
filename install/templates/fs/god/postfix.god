# run with:  god -c /etc/god/postfix.god
#

God.watch do |w|
  w.name = "postfix"
  w.group = "mailserv"
  w.interval = 30.seconds # default
  w.start = "rcctl start postfix"
  w.stop = "rcctl stop postfix"
  w.restart = "rcctl restart postfix"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/spool/postfix/pid/master.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end

end
