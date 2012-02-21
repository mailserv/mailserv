#!/usr/local/bin/ruby
require 'fileutils' 
include FileUtils

template_dir = File.join(File.dirname(__FILE__), '../templates/postfix')

if ARGV[0] == "install"
  install("#{template_dir}/main.cf",   "/etc/postfix/", :mode => 644)
  install("#{template_dir}/master.cf", "/etc/postfix/", :mode => 644)
  install("#{template_dir}/header_checks.pcre", "/etc/postfix/", :mode => 644)
  install("#{template_dir}/milter_header_checks", "/etc/postfix/", :mode => 644)
end

#
# Make sure the /etc/postfix/sql directory exists and is executable
#
mkdir("/etc/postfix/sql") unless File.directory?("/etc/postfix/sql")
chmod(755, "/etc/postfix/sql") unless File.executable?("/etc/postfix/sql")

#
# Install the /etc/postfix/sql files
#
["domains.cf", "email2email.cf", "forwardings.cf", "group.cf", "mailboxes.cf", "routing.cf", "user.cf" ].each do |file|
  install("#{template_dir}/sql/#{file}", "/etc/postfix/sql/") unless File.exists?("/etc/postfix/sql/#{file}")
end

# Make sure that the mailer is being set
unless `grep "/usr/libexec" /etc/mailer.conf | wc -l`.to_i.zero?
  %x{/usr/local/sbin/postfix-enable > /dev/null 2>&1}
end

# Make sure Sendmail is stopped because Postfix is used as MTA
if `pgrep sendmail > /dev/null; echo $?`.to_i.zero?
  `pkill -9 sendmail`
end
