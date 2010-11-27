module Greylist::WhitelistHelper

  def description_form_column(record, options)
    text_area(:record, :description, :size => "60x2", :class => "accepted_filetypes-input text-input as-form-wide")
  end

end
