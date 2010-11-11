class DashboardController < ApplicationController

  def index
    @proc = Mailserver.new.processes
    @updates = Mailserver.new.updates
    Rrdmon.new.daily
  end

  def dns_test
    begin
      @test = NetTest.dns
    rescue
      @test = false
    end
    render :partial => 'display_enabled'
  end

  def http_test
    begin
      @test = NetTest.http
    rescue
      @test = false
    end
    render :partial => 'display_enabled'
  end

  def https_test
    begin
      @test = NetTest.https
    rescue
      @test = false
    end
    render :partial => 'display_enabled'
  end

end
