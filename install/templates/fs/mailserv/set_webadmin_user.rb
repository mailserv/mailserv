#!/usr/local/bin/ruby

#trap "SIGINT", "" 	# Don't exit on ^C

def check(user, pw1, pw2)
  case
  when user.strip.length == 0
    print "Please enter a username\n"
    return false
  when pw1.strip != pw2.strip
    print "passwords don't match\n"
    return false
  when pw1.strip.length < 6
    print "passwords should be longer than 6 characters\n"
    return false
  default
    return true
  end
end

print "Username: "
name = gets
print "Password: "
system 'stty -echo'
pw1 = gets
system 'stty echo'

print "\nPassword again: "
system 'stty -echo'
pw2 = gets
system 'stty echo'
print "\n"

while check(name,pw1,pw2) == false do
  print "Username: "
  name = gets
  print "Password: "
  system 'stty -echo'
  pw1 = gets
  system 'stty echo'

  print "\nPassword again: "
  system 'stty -echo'
  pw2 = gets
  system 'stty echo'
  print "\n"
end

`/usr/local/bin/mysql mail -e "insert into admins (username, password, created_at, updated_at) \
  values ("'"#{name.strip}"'","'"#{pw1.strip}"'",NOW(), NOW());"`
