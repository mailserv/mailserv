require File.dirname(__FILE__) + '/../../test_helper'
require 'system/console_controller'

# Re-raise errors caught by the controller.
class System::ConsoleController; def rescue_action(e) raise e end; end

class System::ConsoleControllerTest < Test::Unit::TestCase
  def setup
    @controller = System::ConsoleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
