#!/bin/sh

if [[ `uname -s` != "OpenBSD" ]]; then
  echo "This only works on OpenBSD!"
  exit 1
fi

# git checkout branch for supported OpenBSD version or development branch
if [ "`echo $1`" == "--devel" ]; then 
  checkout_switch="devel"
elif [ "`echo $1`" == "--help" ]; then
  echo "Usage: install.sh [OPTION]"
  echo " "
  echo "    Without option it installs a stable Mailserv if compatible with your OBSD version."
  echo "    --devel    use only in case you want to try to intall on unsupported OBSD version" 
  echo "    --help     show this info"
  echo " "
  exit 1
else
  checkout_switch=`uname -r`
fi

git --git-dir=/var/mailserv/.git --work-tree=/var/mailserv checkout $checkout_switch 2>/dev/null               
if [[ `echo $?` -ne 0 ]]; then                             # and if that fails
 echo "Mailserv is not yet supported on OpenBSD `uname -r`, please use a supported version of OpenBSD"
 exit 1
fi

 
if [[ ! -d /usr/X11R6 ]]; then
  echo "You need to install the xbaseXX.tgz package for this to work"
  exit 1
fi

for file in `ls /var/mailserv/install/scripts/*`; do
  echo $file
  $file install 2>&1 | tee -a /var/log/install.log
done

/usr/local/bin/god quit
/var/mailserv/scripts/mailserv_boot.sh

echo ""
echo ""
echo "#############################################"
echo ""
echo "All components added."
echo ""

rake -s -f /var/mailserv/admin/Rakefile  mailserv:add_admin

echo ""
echo "Installation complete."
echo ""
echo "Please browse to port 4200 to continue setting up Mailserv."
echo ""
