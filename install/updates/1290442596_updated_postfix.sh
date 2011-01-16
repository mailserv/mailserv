#!/bin/sh

if [ X"$PKG_PATH" == X"" ]; then
  PKG_PATH=http://ftp.OpenBSD.org/pub/OpenBSD/`uname -r`/packages/`uname -m`/
  export PKG_PATH
fi

rm /usr/local/bin/mailserver
install -m 755 /var/mailserv/install/templates/fs/bin/mailserv /usr/local/bin/

pkg_delete postfix
cat <<__EOT
You will be prompted to install a postfix version. The recommendation is to install
the latest stable version:

__EOT
pkg_add -i postfix--mysql
install -m 644 /var/mailserv/install/templates/dovecot.conf /etc/

install -m 644 /var/mailserv/install/templates/fs/god/* /etc/god
/usr/local/bin/god quit
/usr/local/bin/god -c /etc/god/god.conf
