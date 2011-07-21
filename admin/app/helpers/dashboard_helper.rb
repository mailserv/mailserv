module DashboardHelper
  
  def display_enabled(enabled)
    if enabled
      image_tag "bullet_green.png"
    else
      image_tag "bullet_red.png"
    end
  end

end
