class Spamcontrol < ActiveRecord::BaseWithoutTable
  column :required_score, :decimal
  column :rewrite_header, :string
  column :trusted_networks, :string
  column :kill_level, :integer
  
  validates_numericality_of :kill_level, :only_integer => true
  validates_numericality_of :required_score

  def after_initialize
    self.required_score = ActiveRecord::Base.connection.execute("select value from userpref where preference='required_score'").fetch_row.first.to_f rescue 5.0
    self.rewrite_header = ActiveRecord::Base.connection.execute("select value from userpref where preference='rewrite_header Subject'").fetch_row.first.to_s rescue "[SPAM _SCORE_]"
    self.trusted_networks = find_trusted_networks.join(", ")
    self.kill_level = Sudo.read("/etc/postfix/header_checks.pcre").match(/X\-Spam\-Level.*\{(\d+)/)[1] rescue 15
  end

  def find_trusted_networks
    networks = []
    results = ActiveRecord::Base.connection.execute("select value from userpref where preference='trusted_networks'")
    while network = results.fetch_row
      networks << network.to_s
    end
    networks.compact.uniq
  end

  def save
    if valid?
      ActiveRecord::Base.connection.execute("update userpref set value='#{required_score}' where preference='required_score' and username='@GLOBAL'")
      ActiveRecord::Base.connection.execute("update userpref set value='#{rewrite_header}' where preference='rewrite_header Subject' and username='@GLOBAL'")
      ActiveRecord::Base.connection.execute("delete from userpref where preference='trusted_networks'")
      trusted_networks.split(/[\s,]+/).compact.uniq.each do |network|
        ActiveRecord::Base.connection.execute("insert into userpref (username, preference, value) values ('@GLOBAL', 'trusted_networks', '#{network}')") unless network.blank?
      end
      trusted_networks_a = ["127.0.0.0/8"]
      trusted_networks_a += trusted_networks.split(/[\s,]+/).compact.uniq
      Sudo.exec("/usr/local/sbin/postconf -e 'mynetworks=#{trusted_networks_a.join(" ")}'")
      Sudo.write("/etc/postfix/header_checks.pcre", header_checks(kill_level))
      Sudo.exec("/usr/local/sbin/postfix reload")
      true
    end
  end

  def header_checks(kill_level)
    out = ""
    Sudo.read("/etc/postfix/header_checks.pcre").each_line do |line|
      out += line unless line.match(/X\-Spam\-Level/)
    end rescue ""
    "/^X-Spam-Level:\s+\*{#{kill_level},}/ DISCARD\n" + out
  end

end
