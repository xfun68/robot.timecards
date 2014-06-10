class Message
  def self.time_cards_remind(name)
    create_message __method__, name
  end

  def self.missing_mobiles(emails)
    names = emails.map { |email| email.split('@').first }
    create_message(__method__, names.join(','))
  end

  def self.reminded_contacts(contacts)
    names = contacts.map { |contact| contact.email }.map { |email| email.split('@').first }
    create_message(__method__, names.join(','))
  end

  private

  def self.create_message(template_name, content)
    template = load_template template_name
    template.sub /<_PLACEHOLDER_>/, content
  end

  def self.load_template(name)
    File.read "./data/templates/#{name}.txt"
  end
end

