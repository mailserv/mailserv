
if [[ "$1" == "install" ]]; then
cat <<EOF >> /etc/ssh/ssh_config
Host github.com
  StrictHostKeyChecking no
Host anoncvs.openbsd.org
  StrictHostKeyChecking no
EOF
fi

echo "Downloading or updating the minimal ports directory"
echo "-------------------------------------------"
VER="OPENBSD_"`uname -r | sed 's/\./_/'`
if [ ! -d /usr/ports ]; then
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports/infrastructure
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports/mail/postfix
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports/devel/pcre
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports/security/cyrus-sasl2
  cd /usr && cvs -d anoncvs@anoncvs.openbsd.org:/cvs get -r${VER} ports/databases/mysql

  echo "Building Custom packages"
  echo "------------------------"
  cd /usr/ports/mail/postfix/stable       && env FLAVOR="mysql sasl2" make install clean

else
  cd /usr/ports/infrastructure        && cvs -q up -PAd -r${VER}
  cd /usr/ports/mail/postfix          && cvs -q up -PAd -r${VER}
  cd /usr/ports/devel/pcre            && cvs -q up -PAd -r${VER}
  cd /usr/ports/security/cyrus-sasl2  && cvs -q up -PAd -r${VER}
  cd /usr/ports/databases/mysql       && cvs -q up -PAd -r${VER}

  echo "Updating Custom packages"
  echo "------------------------"
  cd /usr/ports/mail/postfix/stable   && env FLAVOR="mysql sasl2" make update clean

fi
