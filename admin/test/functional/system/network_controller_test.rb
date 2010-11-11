require File.dirname(__FILE__) + '/../../test_helper'
require 'system/network_controller'

# Re-raise errors caught by the controller.
class System::NetworkController; def rescue_action(e) raise e end; end

class System::NetworkControllerTest < Test::Unit::TestCase
  def setup
    @controller = System::NetworkController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
