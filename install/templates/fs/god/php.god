God.watch do |w|
  w.name = "php"
  w.interval = 30.seconds 
  w.pid_file = "/var/run/php-fpm.pid"
  w.start = "/usr/local/sbin/php-fpm-5.3 -y /etc/php-fpm.conf"
  w.stop = "kill `cat /var/run/php-fpm.pid`"
  w.restart = "kill -HUP `cat /var/run/php-fpm.pid`"
  w.start_grace = 20.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/run/php-fpm.pid" 

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
