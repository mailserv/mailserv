#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

#---------------------------------------------------------------
#  increase openfiles limit to 1024 ( obsd usualy runs 128 )
#  necessary to dovecot start up
#  (when server reboot limits are read from login.conf, sysctl.conf) 
#---------------------------------------------------------------
maxfilestest=$( ulimit -n )

if [ $maxfilestest -lt 1024 ];
  then
    echo " "
    echo " setting openfiles-max to 1024 "
    echo " "
    ulimit -n 1024
fi

#----------------------------------------------------------------
# increase kern.maxfiles (important for dovecot)
#----------------------------------------------------------------

kernmaxfiles=$( sysctl -n kern.maxfiles )
kernmaxnew=10000

if [ $kernmaxfiles -lt $kernmaxnew ];
  then
   echo " "
   echo " setting kernmaxfiles "
   echo "kern.maxfiles=$kernmaxnew" >> /etc/sysctl.conf
fi
