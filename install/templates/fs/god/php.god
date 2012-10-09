God.watch do |w|
  w.name = "php"
  w.interval = 30.seconds # default
  w.start = "/usr/local/sbin/php-fpm-5.3 -y /etc/php-fpm.conf"
  w.start_grace = 20.seconds
  w.restart_grace = 10.seconds

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
