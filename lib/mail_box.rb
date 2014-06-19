require_relative 'common'
require 'mail'

class MailBox
  def self.first
    return Mail.read('./samples/email.eml') if is_debug?
    [Mail.first].flatten.first
  end

  def self.send(receiver, sender, title, content)
    email_of_admins = Admins.map { |admin| admin.email }

    if is_debug?
      puts "to #{receiver}"
      puts "cc #{email_of_admins}"
      puts "from #{sender}"
      puts "title #{title}"
      puts "body #{content}"
      return
    end

    Mail.deliver do
      to receiver
      cc email_of_admins
      from sender
      subject title
      body content
    end
  end
end

