require File.dirname(__FILE__) + '/../test_helper'
require 'license_controller'

# Re-raise errors caught by the controller.
class LicenseController; def rescue_action(e) raise e end; end

class LicenseControllerTest < Test::Unit::TestCase
  def setup
    @controller = LicenseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
