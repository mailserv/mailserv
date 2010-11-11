require File.dirname(__FILE__) + '/../../test_helper'
require 'system/backup_controller'

# Re-raise errors caught by the controller.
class System::BackupController; def rescue_action(e) raise e end; end

class System::BackupControllerTest < Test::Unit::TestCase
  def setup
    @controller = System::BackupController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
