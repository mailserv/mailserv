module DomainsHelper

  def quota_column(record)
    (record.quota.blank? ? "-" : record.quota.to_s + " MB")
  end

  def quotamax_column(record)
    (record.quotamax.blank? ? "-" : record.quotamax.to_s + " MB")
  end

end
