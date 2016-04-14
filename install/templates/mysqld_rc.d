
rc_pre() {
    mkdir -p /var/run/mysql
    chown -R _mysql:_mysql /var/run/mysql
}