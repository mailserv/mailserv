#!/bin/sh

# Copy the Clam DB from 2008-12-03 (as a starting point)
# and make sure that _clamav can update it.
if [ ! -f /var/db/clamav/main.cld ]; then
  cp -rp /distfiles/clamav /var/db
  chown -R _clamav:_clamav /var/db/clamav
fi
