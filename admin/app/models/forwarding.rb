class Forwarding < ActiveRecord::Base
  belongs_to :domain
  validates_presence_of :source, :destination
  validates_uniqueness_of :source, :case_sensitive => false

  def validate
    source =~ /^([^@\s]*)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
    errors.add("source", "is for the wrong domain") unless $2 == domain.domain
  end

  def to_label
    source
  end

end
