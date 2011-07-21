require File.dirname(__FILE__) + '/../../test_helper'
require 'system/activate_controller'

# Re-raise errors caught by the controller.
class System::ActivateController; def rescue_action(e) raise e end; end

class System::ActivateControllerTest < Test::Unit::TestCase
  def setup
    @controller = System::ActivateController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
