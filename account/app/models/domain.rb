class Domain < ActiveRecord::Base
	has_many :users
  has_many :forwardings
  has_many :administrators
  has_many :admins, :through => :administrators, :source => :user
  validates_presence_of :domain
  validates_numericality_of :quota, :quotamax, :only_integer => true, :allow_blank => true

  def to_label
    domain
  end

  def user_count
    self.users.count
  end

  def forwarding_counts
    self.forwardings.count
  end

  def after_create
    Dir.mkdir("/var/mailserv/mail/" + domain)
  end

  def before_update
    @oldname = Domain.find(id).domain
  end

  def validate_on_create
    if !License.find(:first) && Domain.count > 0
      errors.add_to_base("You need to activate the virtual appliance to add more domains")
    end
  end

  def after_update
    File.rename("/var/mailserv/mail/" + @oldname, "/var/mailserv/mail/" + domain)
  end

  def after_save
    system("/usr/local/bin/rake RAILS_ENV=production -f /var/mailserv/admin/Rakefile mailserver:configure:domains &")
  end

  def before_destroy
    @oldname = Domain.find(id).domain
    @oldid = id
    self.users.each do |user|
      user.destroy
    end
    self.forwardings.each do |forwarding|
      forwarding.destroy
    end
  end

  def after_destroy
    rm_rf("/var/mailserv/mail/" + @oldname)
  end

end
