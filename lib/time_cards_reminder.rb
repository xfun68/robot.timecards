require_relative './mail_actor'
require_relative './sms'
require_relative './missing_time_cards_parser'
require_relative './message'

class TimeCardsReminder < MailActor
  def self.match?(mail)
     /Report: CN Missing Timecards Last Week/i =~ mail.subject
  end

  def initialize(mail)
    super mail
    @reminded_contacts = []
    @sms = Sms.new SMS_SERVICE
  end

  def do
    email_addresses = MissingTimeCardsParser.parse @mail

    send_reminding_messages_to email_addresses
    send_notifications_to_admins email_addresses
  end

  private

  def send_reminding_messages_to(email_addresses)
    contacts = []
    email_addresses.each do |email|
      contact = Contact.find_by_email email
      contacts << contact if is_available_contact? contact
    end

    @reminded_contacts = contacts.select do |contact|
      @sms.send contact.mobile, Message.time_cards_remind(contact.name)
    end
  end

  def send_notifications_to_admins(email_addresses)
    emails_without_mobile = []
    email_addresses.each do |email|
      contact = Contact.find_by_email email
      emails_without_mobile << email unless is_available_contact? contact
    end

    Admins.each do |admin|
      @sms.send(admin.mobile, Message.reminded_contacts(@reminded_contacts))
      @sms.send(admin.mobile, Message.missing_mobiles(emails_without_mobile)) if emails_without_mobile.any?
    end
  end

  def is_available_contact?(contact)
    contact && contact.is_valid_chinese_mobile?
  end
end

