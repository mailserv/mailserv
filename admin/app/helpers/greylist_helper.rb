module GreylistHelper

  def action_column(record)
    record.action.capitalize
  end

  def clause_column(record)
    case record.clause
    when "addr"
      "IP Address"
    when "domainexact"
      "Domainexact"
    when "domain"
      "Domain"
    when "from"
      "Email"
    end
  end

end
