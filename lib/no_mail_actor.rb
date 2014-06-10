require_relative './mail_actor'

class NoMailActor < MailActor
  def self.match?(mail)
    mail.nil?
  end

  def do
    puts 'There is no unread mails.'
  end
end

