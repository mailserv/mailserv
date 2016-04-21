#!/bin/sh

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