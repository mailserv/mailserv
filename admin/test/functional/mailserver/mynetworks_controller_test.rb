require File.dirname(__FILE__) + '/../../test_helper'
require 'mailserver/mynetworks_controller'

# Re-raise errors caught by the controller.
class Mailserver::MynetworksController; def rescue_action(e) raise e end; end

class Mailserver::MynetworksControllerTest < Test::Unit::TestCase
  def setup
    @controller = Mailserver::MynetworksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
