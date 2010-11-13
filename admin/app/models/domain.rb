class Domain < ActiveRecord::Base
	has_many :users
  has_many :forwardings
  has_many :administrators
  has_many :admins, :through => :administrators, :source => :user
  validates_presence_of :domain
  validates_uniqueness_of :domain
  validates_numericality_of :quota, :quotamax, :only_integer => true

  def to_label
    domain
  end

  def after_initialize
    if new_record?
      self.quota = 5000
      self.quotamax = 10000
    end
  end

  def user_count
    self.users.count
  end

  def forwarding_counts
    self.forwardings.count
  end

  def after_create
    %x{sudo mkdir -m 755 /var/mailserver/mail/#{domain}} if Rails.env == "production"
  end

  def before_update
    @oldname = Domain.find(id).domain
  end

  def domain=(domain)
    write_attribute :domain, domain.downcase
  end

  def after_update
    if Rails.env == "production" && @oldname != domain
      %x{sudo mv /var/mailserver/mail/#{@oldname} /var/mailserver/mail/#{domain}}
    end
  end

  def after_save
    system("/usr/local/bin/rake RAILS_ENV=production -f /var/www/admin/Rakefile mailserver:configure:domains &") if Rails.env == "production"
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
    %x{sudo rm -rf /var/mailserver/mail/#{@oldname}} if Rails.env == "production"
  end

end
