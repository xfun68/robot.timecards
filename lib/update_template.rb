require_relative './mail_actor'
require_relative './template_update_parser'

class UpdateTemplate < MailActor
  def self.match?(mail)
     /Update Template:/i =~ mail.subject
  end

  def do
    parser = TemplateUpdateParser.new
    parser.parse @mail

    if (parser.name.nil? || parser.template.nil?)
      puts 'Update template failed.'
      return
    end

    filename = "./data/templates/#{parser.name}.txt"
    File.write filename, parser.template
    puts "Template '#{parser.name}' updated to be '#{parser.template}'"
  end
end

