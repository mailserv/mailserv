class Forwarding < ActiveRecord::Base
  belongs_to :domain
  validates_presence_of :source, :destination
  validates_uniqueness_of :source, :case_sensitive => false

  def before_validation
    self.source = source + "@" + domain.name unless source.match(/@/)
  end

  def validate
    source =~ /^([^@\s]*)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
    errors.add("source", "needs to be in the #{domain.name} domain") unless $2 == domain.name
  end

  def to_label
    source
  end

end
