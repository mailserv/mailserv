class Certificate
  attr_reader :key, :cert, :c, :st, :l, :o, :ou, :cn, :email

  def initialize
    @keyfile            = "/etc/ssl/private/server.key"
    @certfile           = "/etc/ssl/server.crt"
    @key                = File.read(@keyfile)
    @cert               = File.read(@certfile)
    @cn                 = %x{hostname}.strip
  end

  def key=(key)
    File.open(@keyfile, "w") do |f|
      f.puts key
    end
  end

  def cert=(cert)
    File.open(@certfile, "w") do |f|
      f.puts cert
    end
  end

  def gen_key
    %x{openssl genrsa -out #{@keyfile} 2048 2>/dev/null}
  end

  def gen_selfsigned(options = {})
    system("/usr/local/bin/mailserver system:reload_hostname")
  end

  def gen_csr(c = "", st = "", l = "", o = "", ou = "", cn = "", email = "")
    cn = %x{hostname}.strip unless cn.blank?
    subj  = ""
    subj += "/C=#{c}"   unless c.blank?
    subj += "/ST=#{st}" unless st.blank?
    subj += "/L=#{l}"   unless l.blank?
    subj += "/O=#{o}"   unless o.blank?
    subj += "/OU=#{ou}" unless ou.blank?
    subj += "/CN=#{cn}" 
    subj += "/emailAddress=#{email}" unless email.empty?
    %x{openssl req -new -key #{@keyfile} -subj "#{subj}" 2>/dev/null}.strip
  end

  def view
    %x{openssl x509 -text -in #{@certfile}}.strip
  end

  def selfsigned?
    text = %x{/usr/sbin/openssl x509 -text -noout -in #{@certfile}}.strip
    subject = text.match(/Subject:.*CN=(.*)[,\n]/)[1]
    issuer  = text.match(/Issuer.*CN=(.*)[,\n]/)[1]
    issuer == subject
  end

  def subject
    %x{openssl x509 -text -in /etc/ssl/server.crt  | egrep "(Subject:)" | awk '{print $2}'}.strip
  end

  def issuer
    %x{openssl x509 -text -in /etc/ssl/server.crt  | egrep "(Issuer:)" | awk '{print $2}'}.strip
  end

  def verify(certificate, key)
    f = Tempfile.new("certfile")
    f.puts certificate
    f.close
    cert_modulus = %x{openssl x509 -noout -modulus -in #{f.path}}.strip
    f = Tempfile.new("keyfile")
    f.puts key
    f.close
    key_modulus = %x{openssl rsa -noout -modulus -in #{f.path}}.strip

    cert_modulus == key_modulus
  end

end
