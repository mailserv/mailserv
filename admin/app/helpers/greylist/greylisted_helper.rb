module Greylist::GreylistedHelper

  def updated_at_column(record)
    time_ago_in_words(record.updated_at) + " " + t('ago')
  end

end
