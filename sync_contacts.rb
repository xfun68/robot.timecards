require 'watir-webdriver'

CONTACTS_URL = 'https://contacts.thoughtworks.com/'

browser = Watir::Browser.new :firefox
browser.goto CONTACTS_URL

browser.text_field(name: 'username').set(ENV['TW_USERNAME'])
browser.text_field(name: 'password').set(ENV['TW_PASSWORD'])
browser.button(name: 'login').click

# You need to fill the OKTA code now

Watir::Wait.until { browser.url == CONTACTS_URL }

puts browser.url

emails = File.readlines('./data/consultants.csv')[1..-1].map do |line|
  line.split(',').first + '@thoughtworks.com'
end

contacts = emails.inject('') do |memo, email|
  print "Querying mobile for #{email}..."
  browser.text_field(name: 'searchQuery').set(email)
  browser.button(id: 'searchBtn').click

  email_element = browser.li(class: 'email').a
  email_address_with_name = email_element.exists? ? email_element.text : email

  begin
    browser.div(class: 'search-result').wait_until_present 10

    mobiles = browser.div(class: 'search-result').links(href: /tel:/).map { |link| link.href.delete('tel:').gsub(/%20/, '') }
    mobile = [mobiles, 'N/A'].flatten.select { |phone| not phone.empty? and not phone =~ /^und/ }.first # mobile > work phone > N/A

    result = "#{email_address_with_name},#{mobile}"
    puts result

    memo += "#{result}\n"
  rescue Watir::Wait::TimeoutError
    puts 'No contacts matching this query!'
    memo
  end
end

File.write('./data/contacts.csv', contacts)

browser.close

