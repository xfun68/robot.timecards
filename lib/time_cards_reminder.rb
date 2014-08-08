require_relative './mail_actor'
require_relative './mail_box'
require_relative './sms'
require_relative './missing_time_cards_parser'
require_relative './time_card_status_parser'
require_relative './message'
require_relative '../lib/config'

class TimeCardsReminder < MailActor
  def self.match?(mail)
     /Report: CN Missing Timecards Last Week/i =~ mail.subject
  end

  def initialize(mail)
    super mail
    @reminded_contacts = []
  end

  def do
    if (@mail.date.monday?)
      time_card_status = TimeCardStatusParser.parse @mail
      send_time_card_status time_card_status
    end

    if (@mail.date.tuesday?)
      time_card_status = TimeCardStatusParser.parse @mail
      if time_card_status.any? {|office, missing_cnt| missing_cnt != 0}
        send_time_card_status time_card_status
      end
    end

    email_addresses = MissingTimeCardsParser.parse @mail

    send_reminding_messages_to email_addresses
    send_missing_mobile_reminding_to email_addresses
    send_notifications_to_admins email_addresses
  end

  private

  def send_time_card_status(time_card_status)
    status = time_card_status.reduce("\n") do |content, (key, value)|
      if value == 0
        # content += '<li>' + key.to_s + ": " + value.to_s + '</li>'
        content += key.to_s + ": " + value.to_s + "\n"
      else
        # content += '<li><b style="background-color:yellow;">' + key.to_s + ": " + value.to_s + '</b></li>'
        content += '*' + key.to_s + ": " + value.to_s + "\n"
      end
    end
    MailBox.send nil, OP_AND_RM, [ALL_CHINA_THOUGHTWORKS], get_subject("time_card_status_notification"), Message.time_card_status_notification(status)
  end

  def send_missing_mobile_reminding_to(email_addresses)
    email_without_mobile = []
    email_addresses.each do |email|
      contact = Contact.find_by_email email
      email_without_mobile << email unless is_available_contact? contact
    end

    email_without_mobile.each do |email|
      MailBox.send email, RESOURCE_MANAGER_GROUP, get_subject('missing_mobiles_remind'), Message.missing_mobiles_remind(email.split('@').first)
    end
  end

  def send_reminding_messages_to(email_addresses)
    contacts = []
    email_addresses.each do |email|
      contact = Contact.find_by_email email
      contacts << contact if is_available_contact? contact
    end
    @reminded_contacts = contacts
    contacts.select do |contact|
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
      MailBox.send([CHINA_OFFICEPRINCIPALS, CHINA_DELIVERY_SERVICE], get_subject("missing_time_cards_notification"), Message.missing_time_cards_notification(@reminded_contacts))
      if emails_without_mobile.any?
        MailBox.send(RESOURCE_MANAGER_GROUP, get_subject("missing_mobiles_notification"), Message.missing_mobiles_notification(emails_without_mobile))
      end
      @sms.send(admin.mobile, Message.missing_time_cards_notification(@reminded_contacts))
      @sms.send(admin.mobile, Message.missing_mobiles_notification(emails_without_mobile)) if emails_without_mobile.any?
    end
  end

  def get_subject(typ)
    all = File.read("./data/templates/#{typ}.txt")
    all.to_s.split('\\\\\\\\\\')[0].to_lf.gsub("\n", '')
  end

  def is_available_contact?(contact)
    contact && contact.is_valid_chinese_mobile?
  end
end

