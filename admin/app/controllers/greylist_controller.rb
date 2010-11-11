class GreylistController < ApplicationController
  after_filter :after_reorder, :only => [:reorder]

  active_scaffold :greylist do |config|
    config.label = "Greylist Exceptions"
    config.columns = [:description, :action, :clause, :value, :rcpt]

    config.actions = [:live_search, :create, :update, :list, :delete]
    config.actions << :sortable
    columns[:value].form_ui = :textarea
    columns[:rcpt].form_ui = :textarea

    config.columns[:clause].label = "Match From"
    config.columns[:rcpt].label = "Match Destination Email"
  end

  def save
    if Greylist.new.config_test
      Greylist.new.config_install
      flash[:notice] = "Saved updated greylist configuration"
    else
      flash[:error] = Greylist.new.config_errors
    end
    redirect_to :action => :index
  end

  def toggle_greylist
    if Greylist.enabled?
      Greylist.disable
      flash[:notice] = "Greylist disabled"
    else
      Greylist.enable
      flash[:notice] = "Greylist enabled"
    end
    redirect_to :action => :index
  end

  def whitelisted
    @whitelisted = Greylist.whitelisted
  end

  def greylisted
    @greylisted = Greylist.greylisted
  end

  private
  
  def after_reorder
    logger.error "Reorder"
    Greylist.new.after_save
  end

end
