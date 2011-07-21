module System::TimeHelper

  def ntpserver_is_pool?(type)
    " checked=\"checked\"" if type == "servers"
  end

end
