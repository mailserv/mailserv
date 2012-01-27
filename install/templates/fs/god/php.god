God.watch do |w|
  w.name = "php"
  w.uid = "_nginx"
  w.gid = "_nginx"
  w.interval = 30.seconds # default
  w.start = "env PHP_FCGI_CHILDREN=2 /usr/local/bin/php-fastcgi-5.2 -b /tmp/php.sock"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
