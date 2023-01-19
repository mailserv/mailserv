#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

pkg_add -v -m -I postfix-3.8.20220816p0-mysql

template="/var/mailserv/install/templates/postfix"
install -m 644 ${template}/main.cf /etc/postfix
install -m 644 ${template}/master.cf /etc/postfix
install -m 644 ${template}/header_checks.pcre /etc/postfix
install -m 644 ${template}/milter_header_checks /etc/postfix

#
# Make sure the /etc/postfix/sql directory exists and is executable
#
mkdir -p /etc/postfix/sql
chmod 755 /etc/postfix/sql

#
# Install the /etc/postfix/sql files
#
install ${template}/sql/domains.cf      /etc/postfix/sql/
install ${template}/sql/email2email.cf  /etc/postfix/sql/
install ${template}/sql/forwardings.cf  /etc/postfix/sql/
install ${template}/sql/group.cf        /etc/postfix/sql/
install ${template}/sql/mailboxes.cf    /etc/postfix/sql/
install ${template}/sql/routing.cf      /etc/postfix/sql/
install ${template}/sql/user.cf         /etc/postfix/sql/

# Make sure that the mailer is being set
if [[ `grep "/usr/sbin/smtpctl" /etc/mailer.conf | wc -l` -gt 0 ]]; then
    /usr/local/sbin/postfix-enable > /dev/null 2>&1

    #stop smtpd from base
    rcctl stop smtpd; 
    rcctl disable smtpd

    #start postfix
    rcctl enable postfix;
    rcctl start postfix
fi