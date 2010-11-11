require File.dirname(__FILE__) + '/../test_helper'

class ForwardingTest < Test::Unit::TestCase
  fixtures :forwardings

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Forwarding, forwardings(:first)
  end
end
