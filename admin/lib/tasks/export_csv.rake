namespace :mailserv do

  desc "Export the users as csv."
  task :export_csv => :environment do
    csv_string = FasterCSV.generate do |csv|
      # header row
      csv << ["name", "fullname", "password", "quota", "email"]

        # data rows
      User.all.each do |user|
        csv << [user.name, user.fullname, user.password, user.quota, user.email]
      end
    end
    
    File.open("/var/tmp/export.csv", "w") do |f|
      f.puts csv_string
    end
    
    puts "\nThe list of users is availble in /var/tmp/export.csv\n"
  end
  
end
