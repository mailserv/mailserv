class Admin < ActiveRecord::Base
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_confirmation_of :password
  validates_presence_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/, :allow_blank => true
  validates_length_of :password, :minimum => 6
  attr_accessor :pass, :pass_confirmation

  def to_label
    username
  end

  def pass=(password)
    self.password = password unless password.blank?
  end

  def self.authenticate (username, password)
    find(:first, :conditions => [ "username = ? AND password = ?", username, password ])
  end

  def self.emails
    Admin.all.collect(&:email).join(',')
  end

end
