File.readlines('./data/contacts.csv').each do |line|
  email, mobile = line.split ','
  employee_name = email.split('@').first
  filename = "./data/contacts/#{employee_name}.txt"

  puts "#{filename} #{mobile}"

  File.write(filename, mobile)
end

