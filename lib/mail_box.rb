require_relative 'common'
require 'mail'

class MailBox
  def self.first
    return Mail.read('./samples/email.eml') if is_debug?
    [Mail.first].flatten.first
  end

  def self.send(receiver, bcc_receiver=nil, title, content)
    email_of_admins = Admins.map { |admin| admin.email }

    if is_debug?
      puts "=================================================="
      puts "to #{receiver}"
      puts "cc #{email_of_admins}"
      puts "bcc #{bcc_receiver}" unless bcc_receiver.nil? || bcc_receiver.empty?
      puts "from China.Timecard Reminder <timecard-test@thoughtworks.com>"
      puts "title #{title}"
      puts "body #{content}"
    else
      Mail.deliver do
        to receiver
        cc email_of_admins
        bcc bcc_receiver unless bcc_receiver.nil? || bcc_receiver.empty?
        from "China.Timecard Reminder <timecard-test@thoughtworks.com>"
        subject title
        # content_type 'text/html; charset=UTF-8'
        body content
      end
    end
  end
end

