

ActiveRecord::Base.connection.execute("ALTER TABLE users AUTO_INCREMENT = 2000;")
ActiveRecord::Base.connection.execute("grant select on mail.* to 'postfix'@'localhost' identified by 'postfix';")
ActiveRecord::Base.connection.execute("grant all privileges on mail.* to 'mailadmin'@'localhost' identified by 'mailadmin';")
