#!/bin/sh
# ======================================================================
# mailserver backup script
# ----------------------------------------------------------------------
# Created Thu Jan 10 17:51:57 EST 2008, Johan Allard <johan@allard.nu>
# ----------------------------------------------------------------------
# Running this script will backup the mailserver to a remote server
# using a combination of gnutar and ssh.
#
# The schedule is simple, every month on the 1st a full backup is 
# created and every day after than an incremental backup with
# differences from the last monthly backup is created.
# Also, full backups are saved for 1 month after when it's created.
# ----------------------------------------------------------------------

# Need a config file and a ssh key
[[ ! -f /var/mailserver/config/backup_location ]] && exit 1
[[ ! -f /var/mailserver/config/backup_key ]] && exit 1

location=`cat /var/mailserver/config/backup_location`

logtemp=`mktemp /tmp/_logtemp.XXXXXXXXXX`  || exit 1
sshtemp=`mktemp /tmp/_sshtemp.XXXXXXXXXX`  || exit 1
trap 'rm -rf $logtemp $sshtemp; exit 1' 0 1 2 3 13 15

if [ `date +%d` -eq 1 ]; then
  name=backup-`hostname`.full.tgz
  oldname=backup-`hostname`.full-lastmonth.tgz
  logfile=/var/log/backup-full.log
else
  name=backup-`hostname`.incr.`date +%d`.tgz
  logfile=/var/log/backup-incr.log
  timestamp="--newer-mtime=`date +%Y-%m-`01"
fi

# What to back up
files="/var/mailserver /var/db/spamd /var/db/milter-greylist"

echo > $logtemp
echo "------------------------------------------------" | tee -a $logtemp
echo "Backup beginning at `date`" | tee -a $logtemp
echo "------------------------------------------------" | tee -a $logtemp

# If this is a monthly backup, start with moving the current file
# to a one month backup file
[[ "$oldname" != "" ]] && ssh -o StrictHostKeyChecking=no \
  -i /var/mailserver/config/backup_key $location "mv $name $oldname" >/dev/null 2>&1

/usr/local/bin/gtar zvcpf - $timestamp $files 2>> $logtemp |\
  ssh -o StrictHostKeyChecking=no \
  -i /var/mailserver/config/backup_key $location "cat > $name" 2>$sshtemp

if [[ $? -ne 0 ]]; then
  echo "================================================"
  echo "BACKUPS FAILED TO COMPLETE"
  cat $sshtemp
  echo "================================================"
else
  echo 
  echo $((`grep -v "unchanged; not dumped" $logtemp | wc -l` - 5)) "files and directories backed up"
  echo
fi  

echo "------------------------------------------------" | tee -a $logtemp
echo "Backup finished at `date`" | tee -a $logtemp
echo "------------------------------------------------" | tee -a $logtemp  

grep -v "unchanged; not dumped" $logtemp > $logfile
