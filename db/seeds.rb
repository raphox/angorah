User::DEFAULT_USERS.each do |attributes|
  puts "Creating '#{attributes[:first_name]}'"

  User.create(attributes)
end
