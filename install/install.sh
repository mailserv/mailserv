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

for file in `ls /var/mailserv/install/scripts/*`; do
  echo $file
  $file install 2>&1 | tee -a /var/log/install.log
done

/var/mailserv/scripts/mailserv_boot.sh

