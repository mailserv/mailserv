
@spamd_command = "/usr/local/bin/spamd -s mail -u _spamd -dxq -r /var/run/spamd.pid -i 127.0.0.1 --max-spare=5"

God.watch do |w|
  w.name = "spamd"
  w.group = "mailserver"
  w.interval = 30.seconds # default
  w.start = @spamd_command
  w.stop = "kill `cat /var/run/spamd.pid`"
  w.restart = "kill `cat /var/run/spamd.pid`; sleep 1; #{@spamd_command}"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/run/spamd.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
