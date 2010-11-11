require File.dirname(__FILE__) + '/../test_helper'

class RoutingTest < Test::Unit::TestCase
  fixtures :routings
  
  def test_invalid_with_empty_attributes
    mroute = Routing.new
    assert !mroute.valid?
    assert mroute.errors.invalid?(:destination)
    assert mroute.errors.invalid?(:transport)
  end

  def test_duplicate_domains
    mroute = Routing.new(:destination => "springfield.com", :transport => "smtp:1.2.3.4")
    assert !mroute.valid?
  end

  def test_valid_transports
    mroute = Routing.new(:destination => "domain.com", :transport => "smtp:1.2.3.4")
    assert mroute.valid?
    mroute = Routing.new(:destination => "domain.com", :transport => "smtp:smtp.gateway.com")
    assert mroute.valid?
    mroute.transport = ":"
    assert mroute.valid?
  end

  def test_invalid_transport
    mroute = Routing.new(:destination => "domain.com", :transport => "smtp:1.2.3.4.5")
    assert !mroute.valid?
  end

  def test_crud
    mroute = Routing.new(:destination => "validdomain.com", :transport => "smtp:1.2.3.4")
    assert mroute.valid?
    assert mroute.save
    assert mroute.destroy
  end
  
end
