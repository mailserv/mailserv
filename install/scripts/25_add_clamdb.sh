#!/bin/sh

if [ ! -f /var/db/clamav/main.cld ]; then
  echo "Initial download of ClamAV AV Signatures"
  /usr/local/bin/freshclam
  chown -R _clamav:_clamav /var/db/clamav
fi
