require File.dirname(__FILE__) + '/../../test_helper'
require 'system/shutdown_controller'

# Re-raise errors caught by the controller.
class System::ShutdownController; def rescue_action(e) raise e end; end

class System::ShutdownControllerTest < Test::Unit::TestCase
  def setup
    @controller = System::ShutdownController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
