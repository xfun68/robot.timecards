class Message
  def self.time_card_status_notification(content)
    create_message __method__, content
  end

  def self.missing_time_cards_remind(name)
    create_message __method__, name
  end

  def self.missing_time_cards_notification(contacts)
    names = contacts.map { |contact| contact.email }.map { |email| email.split('@').first }
    create_message __method__, names.join(', ')
  end

  def self.missing_mobiles_remind(name)
    create_message __method__, name
  end

  def self.missing_mobiles_notification(emails)
    names = emails.map { |email| email.split('@').first }
    create_message __method__, names.join(', ')
  end

  def self.illegal_hours_remind(weeks_hours)
    create_illegal_remind_message __method__, weeks_hours.map{|key, value| "#{key}  #{value}hrs"}.join(", ")
  end

  def self.illegal_hours_notification(records)
    args = records.map do |record|
      illegal_hours_hint = record[:illegal_hours_weeks].map{|key, value| "#{key} #{value} hrs"}.join(", ")
      "\n#{record[:email].split('@').first}  #{record[:office]}  #{illegal_hours_hint}"
    end
    create_message __method__, args.join("\n")
  end

  private

  def self.create_illegal_remind_message(template_name, content)
    template = load_template template_name
    template.sub /<_PLACEHOLDER_>/, content
  end

  def self.create_message(template_name, content)
    template = load_template template_name
    template = template.split('\\\\\\\\\\')[2].blank?? template : template.split('\\\\\\\\\\')[2]
    template.sub /<_PLACEHOLDER_>/, content
  end

  def self.load_template(name)
    File.read "./data/templates/#{name}.txt"
  end
end

