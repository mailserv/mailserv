#!/bin/sh

if [[ `uname -s` != "OpenBSD" ]]; then
  echo "This only works on OpenBSD!"
  exit 1
fi

#export PKG_PATH=http://ftp.OpenBSD.org/pub/OpenBSD/pub/OpenBSD/`uname -r`/packages/`uname -m`/
export PKG_PATH=http://mirror.internode.on.net/pub/OpenBSD/`uname -r`/packages/`uname -m`/

cat <<EOF >> /etc/ssh/ssh_config
Host github.com
  StrictHostKeyChecking no
Host anoncvs.openbsd.org
  StrictHostKeyChecking no
EOF

echo "Adding packages"
echo "---------------"
pkg_add clamav \
 p5-Mail-SpamAssassin \
 ruby-rails \
 ruby-rrd \
 ruby-mysql \
 ruby-mongrel \
 ruby-fastercsv \
 ruby-highline \
 cyrus-sasl--mysql \
 dovecot--mysql \
 dovecot-sieve \
 mysql-server \
 sqlgrey \
 php5-core \
 php5-mysql \
 php5-fastcgi \
 nginx-- \
 god \
 gtar--

echo "Downloading or updating the minimal ports directory"
echo "-------------------------------------------"
VER="OPENBSD_"`uname -r | sed 's/\./_/'`
if [ ! -d /usr/ports ]; then
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports/infrastructure
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports/mail/postfix
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports/devel/pcre
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports/security/cyrus-sasl2
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports/databases/mysql
else
  cd /usr/ports && cvs -q up -PAd -r${VER}
fi

echo "Building Custom packages"
echo "------------------------"
cd /usr/ports/mail/postfix/stable       && env FLAVOR="mysql sasl2" make install clean


for file in `ls /var/mailserv/install/scripts/*`; do
  $file install 2>&1 | tee -a /var/log/install.log
done
