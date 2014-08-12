require_relative 'common'
require 'mail'

class MailBox
  def self.first
    return Mail.read('./samples/email.eml') if is_debug?
    [Mail.first].flatten.first
  end

  def self.send(receiver, cc_receiver=nil, bcc_receiver=nil, title, content)
    email_of_admins = Admins.map { |admin| admin.email }
    email_cc_receiver = email_of_admins
    email_cc_receiver = email_cc_receiver.concat(cc_receiver) unless cc_receiver.nil?

    if is_debug?
      puts "=================================================="
      puts "to #{receiver}"
      puts "cc #{email_cc_receiver}"
      puts "bcc #{bcc_receiver}" unless bcc_receiver.nil? || bcc_receiver.empty?
      puts "from #{ROBOT_EMAIL_TITLE}"
      puts "title #{title}"
      puts "body #{content}"
    else
      Mail.deliver do
        to receiver
        cc email_cc_receiver
        bcc bcc_receiver unless bcc_receiver.nil? || bcc_receiver.empty?
        from ROBOT_EMAIL_TITLE
        subject title
        # content_type 'text/html; charset=UTF-8'
        body content
      end

    end
  end
end
