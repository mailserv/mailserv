#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

pkg_add -v -m clamav 

# /usr/local/share/examples/clamav/clamd.conf.sample
# /usr/local/share/examples/clamav/freshclam.conf.sample
# /usr/local/share/examples/clamav/clamav-milter.conf.sample

template="/var/mailserv/install/templates"
install -m 644 \
  ${template}/clamd.conf \
  ${template}/freshclam.conf \
  ${template}/clamav-milter.conf \
  /etc

if [ ! -f /var/db/clamav/main.cld ]; then
  echo "Initial download of ClamAV AV Signatures"
  touch /var/log/freshclam.log && chown _clamav:_clamav /var/log/freshclam.log
  
  # Do initial download for clamav
  /usr/local/bin/freshclam --no-warnings
fi

rcctl enable freshclam
rcctl start  freshclam
rcctl enable clamav_milter
rcctl start  clamav_milter
rcctl enable clamd
rcctl start  clamd