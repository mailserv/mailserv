#!/bin/sh
PERCENT=$1
echo "Your mailbox is now $PERCENT% full." | /usr/sbin/sendmail "$USER"
