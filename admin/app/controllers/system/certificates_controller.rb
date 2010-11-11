class System::CertificatesController < ApplicationController
  before_filter :set_certificate

  def upload
    if request.post?
      if @certificate.verify(params[:certificate][:cert].strip, params[:certificate][:key].strip)

        @certificate.key      = params[:certificate][:key].strip
        @certificate.cert     = params[:certificate][:cert].strip
        system_info.reconfig("certificates")
        flash[:notice] = "Certificate and key saved. Reloading services."
      else
        flash[:error] = "Certificate, Key or Certificate Chain is invalid or the key does not match the certificate."
      end
      redirect_to :controller => "System/Certificates", :action => 'upload'
    end
  end

  def csr
    if params[:certificate]
      p = params[:certificate]
      @csr = @certificate.gen_csr(p[:c], p[:st], p[:l], p[:o], p[:ou], p[:cn], p[:email])
      flash[:notice] = "Certificate Signing Request successfully created."
      render :action => 'csr_generated'
    end
  end

  private

  def set_certificate
    @certificate = Certificate.new
  end

end
