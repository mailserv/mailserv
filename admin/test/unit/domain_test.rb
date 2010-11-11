require File.dirname(__FILE__) + '/../test_helper'

class DomainTest < Test::Unit::TestCase
  fixtures :domains

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Domain, domains(:first)
  end
end
