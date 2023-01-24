#!/bin/sh

if [[ `uname -s` != "OpenBSD" ]]; then
  echo "This only works on OpenBSD!"
  exit 1
fi

# git checkout branch for supported OpenBSD version or development branch
# can also specify '--devel <branchname>' to use a specific named branch
if [ "`echo $1`" == "--devel" ]; then
  if [ "`echo $2`" != "" ]; then
    checkout_switch=$2
  else
    checkout_switch="devel"
  fi
  # detect changes in devel branch 
  branch_changes=`git --git-dir=/var/mailserv/.git --work-tree=/var/mailserv status -s`

elif [ "`echo $1`" == "--help" ]; then
  echo "Usage: install.sh [OPTION]"
  echo " "
  echo "    Without option it installs a stable Mailserv if compatible with your OBSD version."
  echo "    --devel    use only in case you want to try to intall on unsupported OBSD version" 
  echo "  or "
  echo "    --devel <another_devel_branch_name> "
  echo "    --help     show this info"
  echo " "
  exit 1
else
  checkout_switch=`uname -r`
fi

if [ ! -z "$branch_changes" ]; then
  echo " "
  echo "Code has been changed manually in Devel branch, system will not replace it from git hub." 
  echo "Please add file(s) and commit changes"
  echo "    cd /var/mailserv "
  echo "    git add <filename>"
  echo "    git commit -a" 
  echo " " 
  echo "This file(s) has been changed or added:"
  echo " $branch_changes "
  echo " "
  exit 1 
else
  # switch to branch  
  git --git-dir=/var/mailserv/.git --work-tree=/var/mailserv checkout $checkout_switch 2>/dev/null                 

  if [[ `echo $?` -ne 0 ]]; then                             # and if that fails
   echo "Mailserv is not yet supported on OpenBSD `uname -r`, please use a supported version of OpenBSD or --devel parameter"
   exit 1
  fi
fi 


if [[ ! -d /usr/X11R6 ]]; then
  echo "You need to install the xbaseXX.tgz package for this to work"
  exit 1
fi

# run all install scripts
for file in `ls /var/mailserv/install/scripts/*`; do
  echo $file
  $file install 2>&1 | tee -a /var/log/install.log
done


sleep 1

/var/mailserv/scripts/mailserv_boot.sh

echo ""
echo "#############################################"
echo ""
echo "All components added."
echo ""

rake -s -f /var/mailserv/admin/Rakefile  mailserv:add_admin

echo "Creating locate database"
/usr/libexec/locate.updatedb

#load PF
/sbin/pfctl -f /etc/pf.conf

echo ""
echo "Installation complete."
echo ""
echo "Please browse to port 4200 to continue setting up Mailserv."
echo ""


