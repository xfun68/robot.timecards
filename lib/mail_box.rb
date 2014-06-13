require_relative 'common'
require 'mail'

class MailBox
  def self.first
    return Mail.read('./samples/email.eml') if is_debug?
    [Mail.first].flatten.first
  end

  def self.send(receiver, sender, title, content)
    Mail.deliver do
      to receiver
      from sender
      subject title
      body content
    end
  end
end

