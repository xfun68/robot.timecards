require_relative './mail_actor'
require_relative '../lib/utility/my_logger'

class UnknownMailActor < MailActor
  def self.match?(mail)
    true
  end

  def do
    MyLogger.instance.warn 'Unknow email: #{@mail.subject}'
  end
end
