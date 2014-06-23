require_relative './mail_actor'
require_relative './mail_box'
require_relative './sms'
require_relative './missing_time_cards_parser'
require_relative './time_card_status_parser'
require_relative './message'

class TimeCardsReminder < MailActor
  def self.match?(mail)
     /Report: CN Missing Timecards Last Week/i =~ mail.subject
  end

  def initialize(mail)
    super mail
    @reminded_contacts = []
  end

  def do
    if (@mail.date.wday == 2)
      time_card_status = TimeCardStatusParser.parse @mail
      send_time_card_status time_card_status
    end

    email_addresses = MissingTimeCardsParser.parse @mail

    send_reminding_messages_to email_addresses
    send_missing_mobile_reminding_to email_addresses
    send_notifications_to_admins email_addresses
  end

  private

  def send_time_card_status(time_card_status)
    status = time_card_status.reduce("\n") do |content, (key, value)|
      content += key.to_s + ": " + value.to_s + "\n"
    end
    MailBox.send nil, "china@thoughtworks.com", "Missing timecard status", Message.time_card_status_notification(status)
  end

  def send_missing_mobile_reminding_to(email_addresses)
    email_without_mobile = []
    email_addresses.each do |email|
      contact = Contact.find_by_email email
      email_without_mobile << email unless is_available_contact? contact
    end

    email_without_mobile.each do |email|
      MailBox.send email, "Timesheet Remind", Message.missing_mobiles_remind(email.split('@').first)
    end
  end

  def send_reminding_messages_to(email_addresses)
    contacts = []
    email_addresses.each do |email|
      contact = Contact.find_by_email email
      contacts << contact if is_available_contact? contact
    end

    @reminded_contacts = contacts.select do |contact|
      @sms.send contact.mobile, Message.missing_time_cards_remind(contact.name)
    end
  end

  def send_notifications_to_admins(email_addresses)
    emails_without_mobile = []
    email_addresses.each do |email|
      contact = Contact.find_by_email email
      emails_without_mobile << email unless is_available_contact? contact
    end

    Admins.each do |admin|
      MailBox.send(admin.email, "SMS send notification", Message.missing_time_cards_notification(@reminded_contacts))
      MailBox.send(admin.email, "Missing mobiles notification", Message.missing_mobiles_notification(emails_without_mobile)) if emails_without_mobile.any?
      @sms.send(admin.mobile, Message.missing_time_cards_notification(@reminded_contacts))
      @sms.send(admin.mobile, Message.missing_mobiles_notification(emails_without_mobile)) if emails_without_mobile.any?
    end
  end

  def is_available_contact?(contact)
    contact && contact.is_valid_chinese_mobile?
  end
end

