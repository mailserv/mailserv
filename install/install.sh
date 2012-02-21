#!/bin/sh

if [[ `uname -s` != "OpenBSD" ]]; then
  echo "This only works on OpenBSD!"
  exit 1
fi

# git checkout branch 5.0 for OpenBSD 5.0
git --git-dir=/var/mailserv/.git --work-tree=/var/mailserv checkout `uname -r` 2>/dev/null             
if [[ `echo $?` -ne 0 ]]; then                             # and if that fails
 echo "Mailserv is not yet supported on OpenBSD `uname -r`, please use a support version of OpenBSD"
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
