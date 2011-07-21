require File.dirname(__FILE__) + '/../../test_helper'
require 'mailserver/routing_controller'

# Re-raise errors caught by the controller.
class Mailserver::RoutingController; def rescue_action(e) raise e end; end

class Mailserver::RoutingControllerTest < Test::Unit::TestCase
  def setup
    @controller = Mailserver::RoutingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
