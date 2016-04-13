
rc_pre() {
    mkdir -p /var/run/memcached
    chown -R _memcached:_memcached /var/run/memcached
}