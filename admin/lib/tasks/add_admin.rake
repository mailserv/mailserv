namespace :mailserv do

  def ask_passwords
    pass1 = ask("Password:  ") do |q|
      q.echo = "*"
      q.validate = /^.{6,31}$/
      q.responses[:not_valid] = "Please use a stronger password (min 6 characters)"
    end
    pass2 = ask("Password Confirm:  ") {|q| q.echo = "*" }

    while pass1 != pass2
      say "\nPasswords don't match"
      pass1 = ask("Password:  ") do |q|
        q.echo = "*"
        q.validate = /^.{6,31}$/
        q.responses[:not_valid] = "Please use a stronger password (min 6 characters)"
      end
      pass2 = ask("Password Confirm:  ") {|q| q.echo = "*" }
    end
    return pass1
  end

  # Alias for add_admin
  task :create_admin do
    Rake::Task['mailserv:add_admin'].execute
  end

  desc "Create a new user."
  task :add_admin => :environment do
    require 'highline/import'

    say "Add an Administrator to the system"

    begin
      begin
        username = ask("username: ", String) do |q|
          q.validate = /^([a-zA-Z0-9\_\-]+)$/
          q.responses[:not_valid] = "Please use characters 'a-z, A-Z, 0-9, _-' only."
        end
        email = ask("E-mail (used to send status updates - not needed): ")
        password = ask_passwords
      end while !agree("Is this correct?  ", true)
  
      admin = Admin.new(:username => username, :email => email,
        :password => password)
      unless admin.save
        say "\n" + admin.errors.full_messages.join(", ") + "\n\n"
      end
    end while !admin.errors.size.zero?
  end
  
end
