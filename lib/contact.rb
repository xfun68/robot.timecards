class Contact
  @@contacts = []

  attr_reader :email

  def self.load(contacts_folder)
    @@contacts = Dir["./data/contacts/*.txt"].map do |file|
      email, mobile = parse_email_and_mobile file
      Contact.new email, mobile
    end

    puts "#{@@contacts.size} contacts loaded."
  end

  def self.find_by_email(email)
    result = @@contacts.select { |contact| contact.match_email? email }
    result.empty? ? nil : result[0]
  end

  def self.create_from_name(name, mobile)
    Contact.new "#{name}@thoughtworks.com", mobile
  end

  def initialize(email, mobile)
    @email = email
    @mobile = mobile
  end

  def match_email?(target_email)
    @email == target_email
  end

  def is_valid_chinese_mobile?
    mobile =~ /^1\d{10}/
  end

  def mobile
    @mobile.delete("^[0-9]").sub(/^0?860?/, '')
  end

  def name
    @email.split('@').first
  end

  private

  def self.parse_email_and_mobile(file)
    name = File.basename(file).split('.').first
    email = "#{name}@thoughtworks.com"
    mobile = File.read(file).gsub(/[^0-9]/, '')
    return email, mobile
  end
end

