module System::UpdateHelper

  def display_progress
    out = ""
    0.upto(@progress[:percent].to_i - 1) do
      out += "&nbsp;"
    end
    out
  end

  def display_remaining
    out = ""
    0.upto(99 - @progress[:percent].to_i) do
      out += "&nbsp;"
    end
    out
  end

  def display_updatelink_name(major, minor)
    out  = "Upgrade to version #{CONF['product'].capitalize} #{major}"
    out += " release #{minor}" if minor
  end

end
