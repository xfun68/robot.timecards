require_relative './mail_actor'

class UnknownMailActor < MailActor
  def self.match?(mail)
    true
  end

  def do
    Admins.each do |admin|
      Sms.new(SMS_SERVICE).send admin.mobile, "Unknown email: '#{@mail.subject}'."
    end
  end
end
