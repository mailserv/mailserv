# run with:  god -c /etc/god/postfix.god
#

God.watch do |w|
  w.name = "postfix"
  w.group = "mailserver"
  w.interval = 30.seconds # default
  w.start = "/usr/local/sbin/postfix start"
  w.stop = "/usr/local/sbin/postfix stop"
  w.restart = "/usr/local/sbin/postfix reload"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/spool/postfix/pid/master.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end

end
