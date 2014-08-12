require_relative './mail_actor'

class TemplateUpdateParser
  attr_reader :name, :template, :admins, :subject

  def parse(mail)
    @name = (/<(\w+)>/.match(mail.subject) || [])[1]
    @template = (/@@@([^@]+)@@@/.match(mail.body.decoded) || [])[1]
    @subject = (/###([^#]+)###/.match(mail.body.decoded) || [])[1]
    @admins = (/"""([^"]+)"""/.match(mail.body.decoded) || [])[1]
  end
end

