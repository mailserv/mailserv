#!/usr/local/bin/ruby
# ======================================================================
# sysmail.rb
# ----------------------------------------------------------------------
# Created Tue Mar 25 20:15:43 EST 2008
# ----------------------------------------------------------------------
# Looks in the database for admins email addresses and delivers mails
# to all of them. The purpose is to be called from the aliases so that
# sysadmin type mails gets delivered to the correct address according
# to the setting in the webadmin database.
# ----------------------------------------------------------------------

recipients = %x{/var/www/admin/script/runner -e production "puts Admin.emails"}.strip
exit if recipients.empty?

IO.popen("/usr/sbin/sendmail #{recipients}","w+") do |sm|
  sm.puts STDIN.read
end
