#!/bin/sh

if [[ `uname -s` != "OpenBSD" ]]; then
  echo "This only works on OpenBSD!"
  exit 1
fi

cat <<EOF >> /etc/ssh/ssh_config
Host github.com
  StrictHostKeyChecking no
Host anoncvs.openbsd.org
  StrictHostKeyChecking no
EOF

for file in `ls /var/mailserv/install/scripts/*`; do
  echo $file
  $file install 2>&1 | tee -a /var/log/install.log
done

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
