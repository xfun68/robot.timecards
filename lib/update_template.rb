require_relative './mail_actor'
require_relative './template_update_parser'

class UpdateTemplate < MailActor
  def self.match?(mail)
     /Update Template:/i =~ mail.subject
  end

  def do
    parser = TemplateUpdateParser.new
    parser.parse @mail

    if parser.name.nil?
      puts 'Update template failed.'
      return
    end

    filename = "./data/templates/#{parser.name}.txt"
    admins_file = "./data/admins.csv"
    File.write filename, "#{parser.subject}\n\\\\\\\\\\\\\\\\\\\\\n#{parser.template}"
    puts "Template '#{parser.name}' updated to be \n-----------------------\nSubject: #{parser.subject}\nMailBody:#{parser.template}'"
    File.write admins_file, parser.admins if !parser.admins.nil?
    puts "Admins are updated to be \n======================\n #{parser.admins}\n======================\n"
  end
end

