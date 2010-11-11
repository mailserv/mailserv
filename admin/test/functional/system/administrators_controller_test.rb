require File.dirname(__FILE__) + '/../../test_helper'
require 'system/administrators_controller'

# Re-raise errors caught by the controller.
class System::AdministratorsController; def rescue_action(e) raise e end; end

class System::AdministratorsControllerTest < Test::Unit::TestCase
  def setup
    @controller = System::AdministratorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
