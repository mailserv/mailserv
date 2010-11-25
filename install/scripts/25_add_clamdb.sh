#!/bin/sh

if [ ! -f /var/db/clamav/main.cld ]; then
  echo "Initial download of ClamAV AV Signatures"
  touch /var/log/clamd.log && chown _clamav:_clamav /var/log/clamd.log
  touch /var/log/clam-update.log && chown _clamav:_clamav /var/log/clam-update.log
  touch /var/log/freshclam.log && chown _clamav:_clamav /var/log/freshclam.log
  
  /usr/local/bin/freshclam
  chown -R _clamav:_clamav /var/db/clamav
fi
