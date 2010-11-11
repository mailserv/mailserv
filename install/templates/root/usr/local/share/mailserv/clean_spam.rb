#!/usr/local/bin/ruby

delete_after = (!ARGV[0].to_i.zero? ? ARGV[0].to_i : 30)

`ls -d /var/mailserv/mail/* 2>/dev/null`.each do |domain|
  domain.strip!
  `ls -d #{domain}/* 2>/dev/null`.each do |user|
    user.strip!
    %x{
      exec 2> /dev/null
      find #{user}/.Spam/cur -ctime +#{delete_after} -exec rm {} \\;
      find #{user}/.Spam/new -ctime +#{delete_after} -exec rm {} \\;
      find #{user}/.Trash/cur -ctime +#{delete_after} -exec rm {} \\;
      find #{user}/.Trash/new -ctime +#{delete_after} -exec rm {} \\;
    }
  end
end
