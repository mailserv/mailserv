#!/bin/sh

if [[ `uname -s` != "OpenBSD" ]]; then
  echo "This only works on OpenBSD!"
  exit 1
fi

if [[ `uname -r ` != "4.9" ]]; then
  echo "OpenBSD 4.9 is required for this upgrade to work properly"
  exit 1
fi

if [[ ! -d /usr/X11R6 ]]; then
  echo "You need to install the xbase49.tgz package for this to work"
  exit 1
fi

echo "Shutting down services."
. /etc/rc.shutdown

echo "Removing old packages"
pkg_delete -F dependencies freetype2 rrdtool milter-greylist curl libiconv postfix god ruby-rack cyrus-sasl

cat <<EOF >> /etc/ssh/ssh_config
Host github.com
  StrictHostKeyChecking no
Host anoncvs.openbsd.org
  StrictHostKeyChecking no
EOF

if [ X"$PKG_PATH" == X"" ]; then
  PKG_PATH=ftp://ftp.OpenBSD.org/pub/OpenBSD/`uname -r`/packages/`uname -m`/
  export PKG_PATH
fi

echo "Adding git"
pkg_add git

echo "Download the Mailserv repository"
cd /var
git clone git://github.com/mailserv/mailserv.git

/usr/sbin/pkg_add -v -u -F update -F updatedepends 2>&1 | tee -a /var/log/upgrade.log
pkg_add -v -m postfix-2.7.1-mysql 2>&1 | tee -a /var/log/upgrade.log
/var/mailserv/install/scripts/10_pkg_add.sh install 2>&1 | tee -a /var/log/upgrade.log
/var/mailserv/install/scripts/20_install_etc.sh install 2>&1 | tee -a /var/log/upgrade.log
/var/mailserv/install/scripts/25_add_clamdb.sh install 2>&1 | tee -a /var/log/upgrade.log

rm /etc/postfix/sql/*
/var/mailserv/install/scripts/30_postfix.rb install 2>&1 | tee -a /var/log/upgrade.log

/var/mailserv/install/scripts/40_permissions.sh install 2>&1 | tee -a /var/log/upgrade.log
/var/mailserv/install/scripts/50_database.sh upgrade 2>&1 | tee -a /var/log/upgrade.log

/usr/local/bin/mysqld_start
/var/mailserv/scripts/install_roundcube
/var/mailserv/scripts/install_awstats

/var/mailserv/install/scripts/70_sqlgrey.sh install 2>&1 | tee -a /var/log/upgrade.log
mv /var/mailserver/mail/* /var/mailserv/mail

rm /etc/postfix/header_checks.pre 2>/dev/null

echo ""
echo "###################"
echo ""
echo "Upgrade completed. Please restart the system."
