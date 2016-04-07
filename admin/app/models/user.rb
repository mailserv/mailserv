class User < ActiveRecord::Base
  belongs_to :domain
  has_many :administrators
  has_many :admin_for, :through => :administrators, :source => :domain
  validates_presence_of :name, :domain_id, :fullname
  validates_format_of :name, :with => /^[a-zA-Z0-9_\.\-]+$/
  validates_uniqueness_of :name, :scope => :domain_id, :case_sensitive => false
  validates_length_of :password1, :minimum => 6, :allow_blank => true
  validates_confirmation_of :password1, :allow_blank => true
  validates_numericality_of :quota, :only_integer => true, :allow_blank => true
  attr_accessor :password1, :password1_confirmation

  def before_create
    self.quota = self.domain.quota if self.domain && self.domain.quota && !self.quota
    ActiveRecord::Base.connection.execute("ALTER TABLE users AUTO_INCREMENT = 2000;") if User.count.zero?
  end

  def before_save
    self.name.downcase!
    self.email = name + "@" + domain.name
    self.home = "/var/mailserv/mail/" + self.domain.name + "/" + name + "/home"
    self.quota = self.domain.quota if self.domain && self.domain.quota && !self.quota
  end

  def password1=(password)
    @password1 = password
    self.password = @password1 unless @password1.blank?
  end

  def after_create
    WebmailUser.create!(
      :username     => self.email,
      :last_login   => Time.new.strftime("%F %T"),
  #    :alias        => self.fullname,
      :created      => Time.new.strftime("%F %T"),
      :language     => "en_US",
      :mail_host    => "localhost",
      :preferences  => 'a:2:{s:16:"message_sort_col";s:4:"date";s:18:"message_sort_order";s:4:"DESC";}'
    )
    vm = WebmailUser.find_by_username(self.email)
    WebmailIdentity.create!(
      :user_id => vm.user_id,
      :name => self.fullname,
      :email => self.email,
      :del => "0",
      :standard => "1",
      :html_signature => "0",
      :organization => '',
      :bcc => '',
      :signature => '',
      "reply-to" => self.email
    )
    %x{
      /usr/local/bin/sudo cp -r /var/mailserv/config/default_maildir /var/mailserv/mail/#{domain.name}/#{name}
      /usr/local/bin/sudo chown -R #{id}:#{id} /var/mailserv/mail/#{domain.name}/#{name}
      find /var/mailserv/mail/#{domain.name}/#{name} -type f -name .gitignore | xargs /usr/local/bin/sudo rm
      find /var/mailserv/mail/#{domain.name}/#{name} -type d | xargs /usr/local/bin/sudo chmod 750
    }
  end

  def before_update
    @oldname = User.find(id).name
  end

  def after_update
    %x{/usr/local/bin/sudo mv /var/mailserv/mail/#{domain.name}/#{@oldname} /var/mailserv/mail/#{domain.name}/#{name}}
  end

  def before_destroy
    logger.info "Deleting user: #{name_and_email}"
    vm = WebmailUser.find_by_username(self.email)
    if vm
      uid = vm.user_id
      uid = WebmailUser.find_by_username(self.email).user_id
      WebmailContact.delete_all ["user_id = ?", uid] if WebmailContact.find(:first, :conditions => ["user_id = ?", uid])
      WebmailIdentity.delete_all ["user_id = ?", uid] if WebmailIdentity.find(:first, :conditions => ["user_id = ?", uid])
      WebmailUser.delete_all ["user_id = ?", uid] if WebmailUser.find(:first, :conditions => ["user_id = ?", uid])
    end
    @oldname = User.find(id).name
  end

  def name_and_email
    (fullname.present? ? "#{fullname} <#{email}>" : email) rescue ""
  end

  def after_destroy
    %x{/usr/local/bin/sudo rm -rf /var/mailserv/mail/#{domain.name}/#{@oldname}}
  end

  def validate
    errors.add("quota", "exceeds domain maximum #{self.domain.quotamax} Mb") if (quota.to_i > self.domain.quotamax.to_i)
  end

  private

  def validate_on_create
    errors.add("password1", "cannot be empty") if password.blank? && password1.blank?
  end

end
