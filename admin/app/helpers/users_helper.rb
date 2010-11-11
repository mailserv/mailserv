module UsersHelper

  def quota_column(record)
    (record.quota.blank? ? "-" : record.quota.to_s + " MB")
  end

  def admin_for_column(record)
    admin_for = (record && record.admin_for ? record.admin_for : [])
    if admin_for.count > 3
      admin_for[0..2].collect(&:domain).join(", ") + " +#{(admin_for.count - 3).to_s}" rescue ""
    else
      admin_for.collect(&:domain).join(", ") rescue ""
    end
  end

end
