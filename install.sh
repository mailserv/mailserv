#!/bin/sh

if [[ `uname -s` != "OpenBSD" ]]; then
  echo "This only works on OpenBSD!"
  exit 1
fi

#export PKG_PATH=http://ftp.OpenBSD.org/pub/OpenBSD/pub/OpenBSD/`uname -r`/packages/`uname -m`/
export PKG_PATH=http://mirror.internode.on.net/pub/OpenBSD/`uname -r`/packages/`uname -m`/

echo "Downloading or updating the ports directory"
echo "-------------------------------------------"
VER="OPENBSD_"`uname -r | sed 's/\./_/'`
if [ ! -d /usr/ports ]; then
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports
else
  cd /usr/ports && cvs -q up -PAd -r${VER}
fi

echo "Added pre-built packages"
echo "------------------------"
pkg_add clamav
pkg_add p5-Mail-SpamAssassin
pkg_add ruby-rails
pkg_add ruby-rrd
pkg_add ruby-mysql
pkg_add ruby-mongrel
pkg_add ruby-fastercsv
pkg_add ruby-highline
pkg_add cyrus-sasl--mysql
pkg_add dovecot--mysql
pkg_add dovecot-sieve
pkg_add mysql-server
pkg_add pcre
pkg_add sqlgrey
pkg_add php5-core
pkg_add php5-mysql
pkg_add php5-fastcgi
pkg_add nginx--
pkg_add git
pkg_add god
pkg_add gtar--

echo "Building Custom packages"
echo "------------------------"
cd /usr/ports/mail/postfix/stable       && env FLAVOR="mysql sasl2" make install clean

echo "Checking out the git repository"
echo "-------------------------------"
cd /var && /usr/local/git clone git@github.com:mailserv/mailserv.git

for file in `ls /var/mailserv/install/scripts/*`; do
  $file install 2>&1 | tee -a /var/log/install.log
done


