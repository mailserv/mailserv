require File.dirname(__FILE__) + '/../../test_helper'
require 'system/dns_controller'

# Re-raise errors caught by the controller.
class System::DnsController; def rescue_action(e) raise e end; end

class System::DnsControllerTest < Test::Unit::TestCase
  def setup
    @controller = System::DnsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
