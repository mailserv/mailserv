class Spamdb

  def stats
    {
      :whitelist => self.whitelist_count,
      :greylist => self.greylist.length,
      :trapped => self.trapped.length
    }
  end

  def whitelist_count
    %x{/usr/sbin/spamdb | egrep "^WHITE" | wc -l}.to_i
  end

  def whitelist(match = "")
    output = Array.new
    %x{/usr/sbin/spamdb | egrep "^WHITE"}.each_line do |line|
      line =~ /\|(.*)\|\|\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)/
      address, first, grey_to_white, expire, blocked, passed = $1, display_time($2), display_time($3), display_time($4), $5, $6
      unless match.blank?
        next unless address.include?(match) || first.to_s.include?(match) || expire.to_s.include?(match) || blocked.to_s.include?(match)
      end        
      next if address.nil? || first.nil? || grey_to_white.nil? || expire.nil? || blocked.nil? || passed.nil?
      output << {
        :address => address,
        :first => first,
        :grey_to_white => grey_to_white,
        :expire => expire,
        :blocked => blocked,
        :passed => passed
        }
    end
    output
  end

  def whitelist=(address)
    %x{/usr/sbin/spamdb -a #{address}}
  end

  def greylist
    output = Array.new
    %x{/usr/sbin/spamdb | egrep "^GREY"}.each_line do |line|
      line =~ /\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)/
      address, helo, from, to, first, grey_to_white, expire, blocked, passed = $1, $2, $3, $4, $5, $6, $7, $8, $9
      next if helo.nil? || address.nil? || from.nil? || to.nil? || first.nil? || grey_to_white.nil? || expire.nil? || blocked.nil? || passed.nil?
      output << {
        :address => address,
        :helo => helo,
        :from => from,
        :to => to,
        :first => display_time(first),
        :grey_to_white => display_time(grey_to_white),
        :expire => display_time(expire),
        :blocked => blocked,
        :passed => passed
      }
    end
    output
  end

  def delete_entry(address)
    %x{/usr/sbin/spamdb -d #{address}}
  end

  def perm_whitelist
    %x{cat /etc/mail/whitelist}.split("\n")
  end

  def perm_whitelist=(address)
    %x{echo #{address} >> /etc/mail/whitelist; /sbin/pfctl -t whitelist -T add #{address}}
  end

  def perm_whitelist_delete(address)
    w = self.whitelist
    w.delete address
    File.open("/etc/mail/whitelist", "w") do |f|
      f.puts w.join("\n")
    end
  end

  def trapped
    output = Array.new
    %x{/usr/sbin/spamdb | egrep "^TRAPPED"}.each_line do |line|
      line =~ /\|(.*)\|(.*)/
      address, expire = $1, $2
      output << {
        :address => address,
        :expire => display_time(expire),
      }
    end
    output
  end

  def trapped_delete(address)
    %x{/usr/sbin/spamdb -t -d #{address}}
  end

  def spamtrap
    %x{/usr/sbin/spamdb | egrep "^SPAMTRAP" | sed 's/\|/ /' | awk '{print $2}'}.split("\n")
  end

  def spamtrap=(address)
    %x{/usr/sbin/spamdb -T -a #{address}}
  end
  
  def spamtrap_delete(address)
    %x{/usr/sbin/spamdb -T -d #{address}}
  end

  private
  
  def display_time(time_since_epoch)
    Time.at(time_since_epoch.to_i)
  end

end