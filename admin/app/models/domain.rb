class Domain < ActiveRecord::Base
	has_many :users
  has_many :forwardings
  has_many :administrators
  has_many :admins, :through => :administrators, :source => :user
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :quota, :quotamax, :only_integer => true

  def to_label
    name
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
    logger.info "Creating directory /var/mailserv/mail/#{name}"
    logger.info %x{/usr/local/bin/sudo mkdir -m 755 /var/mailserv/mail/#{name}}
  end

  def before_update
    @oldname = Domain.find(id).name
  end

  def name=(name)
    write_attribute :name, name.downcase
  end

  def after_update
    if @oldname != name
      %x{/usr/local/bin/sudo mv /var/mailserv/mail/#{@oldname} /var/mailserv/mail/#{name}}
    end
  end

  def after_save
    system("/usr/local/bin/sudo /usr/local/bin/rake RAILS_ENV=production -f /var/mailserv/admin/Rakefile mailserver:configure:domains &") if Rails.env.production?
  end

  def before_destroy
    begin
      logger.info "Deleting domain: #{self.name}" rescue ""
      @oldname = self.name
      self.users.each do |user|
        user.destroy
      end
      self.forwardings.each do |forwarding|
        forwarding.destroy
      end
      true
    rescue
    end
    true
  end

  def after_destroy
    %x{/usr/local/bin/sudo rm -rf /var/mailserv/mail/#{@oldname}} if @oldname.present?
  end

end
