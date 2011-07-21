class Whitelist < ActiveRecord::Base
  validates_uniqueness_of :value, :message => "already whitelisted"

  def after_save
    out_fqdn = "# Generated from Mailserv admin gui. Changes will be overwritten.\n\n"
    out_ip   = "# Generated from Mailserv admin gui. Changes will be overwritten.\n\n"
    Whitelist.all.each do |item|
      if item.value.match(/^[\d\.]+/)
        case
        when item.description.nil?
          out_ip += item.value + "\n"
        when item.description.length > 20
          out_ip += word_wrap(item.description, :line_width => 60).map {|l| "# #{l}"}.to_s + "\n"
          out_ip += item.value + "\n\n"
        else
          out_ip += item.value.ljust(30) + "# #{item.description}\n"
        end
      else
        case
        when item.description.nil?
          out_fqdn += item.value + "\n"
        when item.description.length > 20
          out_fqdn += word_wrap(item.description, :line_width => 60).map {|l| "# #{l}"}.to_s + "\n"
          out_fqdn += item.value + "\n\n"
        else
          out_fqdn += item.value.ljust(30) + "# #{item.description}\n"
        end
      end
    end
    Sudo.write("/etc/sqlgrey/clients_ip_whitelist.local", out_ip + "\n")
    Sudo.write("/etc/sqlgrey/clients_fqdn_whitelist.local", out_fqdn + "\n")
  end

  private

  # Too lazy to figure out how to include the helper right now
  def word_wrap(text, *args)
    options = args.extract_options!
    unless args.blank?
     options[:line_width] = args[0] || 80
    end
    options.reverse_merge!(:line_width => 80)

    text.split("\n").collect do |line|
      line.length > options[:line_width] ? line.gsub(/(.{1,#{options[:line_width]}})(\s+|$)/, "\\1\n").strip : line
    end * "\n"
  end

end
