class Domain < ActiveRecord::Base
	has_many :users
  has_many :forwardings
  has_many :administrators
  has_many :admins, :through => :administrators, :source => :user
  validates_presence_of :domain
  validates_numericality_of :quota, :quotamax, :only_integer => true, :allow_blank => true

  def to_label
    name
  end

  def user_count
    self.users.count
  end

  def forwarding_counts
    self.forwardings.count
  end

  def after_create
    logger.info "Creating directory /var/mailserv/mail/#{name}"
    logger.info %x{sudo mkdir -m 755 /var/mailserv/mail/#{name}}
  end

  def before_update
    @oldname = Domain.find(id).name
  end

  def after_update
    if @oldname != name
      %x{sudo mv /var/mailserv/mail/#{@oldname} /var/mailserv/mail/#{name}}
    end
  end

  def after_save
    system("sudo /usr/local/bin/rake RAILS_ENV=production -f /var/mailserv/admin/Rakefile mailserver:configure:domains &")
  end

  def before_destroy
    @oldname = Domain.find(id).name
    @oldid = id
    self.users.each do |user|
      user.destroy
    end
    self.forwardings.each do |forwarding|
      forwarding.destroy
    end
  end

  def after_destroy
    %x{sudo rm -rf /var/mailserv/mail/#{@oldname}}
  end

end
