require_relative './mail_actor'
require_relative './time_card_hours_parser'
require_relative '../lib/config'

class HoursCheck < MailActor
  def self.match?(mail)
    /Report: CN <40 hours a week/i =~ mail.subject
  end

  def do
    parser = TimeCardHoursParser.new
    parser.parse @mail

    if (parser.records.any?)
      send_illegal_hours_reminding_to parser.records
      send_notifications_to_admins parser.records
      return
    end
  end

  private
  def send_illegal_hours_reminding_to(records)
    records.each do |record|
      email = record[:email]
      message = Message.illegal_hours_remind(record[:illegal_hours_weeks])
      MailBox.send email, OP_AND_RM, get_subject('remind'), message
      # contact = Contact.find_by_email email
      #@sms.send contact.mobile, message if contact && contact.is_valid_chinese_mobile?
    end
  end

  def send_notifications_to_admins(records)
    MailBox.send [CHINA_OFFICEPRINCIPALS, CHINA_DELIVERY_SERVICE], get_subject('notification'), Message.illegal_hours_notification(records)
  end

  def get_subject(typ)
    all = File.read("./data/templates/illegal_hours_#{typ}.txt")
    all.to_s.split('\\\\\\\\\\')[0].to_lf.gsub("\n", '')
  end
end

