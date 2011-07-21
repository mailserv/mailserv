require File.dirname(__FILE__) + '/../../test_helper'
require 'system/update_controller'

# Re-raise errors caught by the controller.
class System::UpdateController; def rescue_action(e) raise e end; end

class System::UpdateControllerTest < Test::Unit::TestCase
  def setup
    @controller = System::UpdateController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
