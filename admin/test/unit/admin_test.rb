require File.dirname(__FILE__) + '/../test_helper'

class AdminTest < Test::Unit::TestCase
  fixtures :admins

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Admin, admins(:first)
  end
end
