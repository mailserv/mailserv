require File.dirname(__FILE__) + '/../test_helper'
require 'domains_controller'

# Re-raise errors caught by the controller.
class DomainsController; def rescue_action(e) raise e end; end

class DomainsControllerTest < Test::Unit::TestCase
  def setup
    @controller = DomainsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
