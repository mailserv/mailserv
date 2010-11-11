require File.dirname(__FILE__) + '/../test_helper'
require 'greylist_controller'

# Re-raise errors caught by the controller.
class GreylistController; def rescue_action(e) raise e end; end

class GreylistControllerTest < Test::Unit::TestCase
  def setup
    @controller = GreylistController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
