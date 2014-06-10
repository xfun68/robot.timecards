require_relative './mail_actor'
require_relative './contact_update_parser'

class UpdateContact < MailActor
  def self.match?(mail)
     /Update Contacts?/i =~ mail.subject
  end

  def do
    parser = ContactUpdateParser.new
    parser.parse @mail

    parser.contacts.each do |contact|
      filename = "./data/contacts/#{contact.name}.txt"
      File.write filename, contact.mobile
      puts "Contact updated: '#{contact.name}' '#{contact.mobile}'"
    end
  end
end

