class MailActor
  def self.create_by(mail)
    actors = [NoMailActor, TimeCardsReminder, UpdateTemplate, UpdateContact, UnknownMailActor]
    actors.each do |actor|
      return actor.new(mail) if actor.match?(mail)
    end
  end

  def self.match?(mail)
    raise 'This method needs to be implemented in sub-classes.'
  end

  def initialize(mail)
    @mail = mail
    archive if @mail
  end

  def archive
    puts "Received email: '#{@mail.subject}'"

    archive_path = 'archives'
    timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    suffix = 'eml'
    filename = "#{archive_path}/#{timestamp}_#{@mail.subject}.#{suffix}"
    File.write filename, @mail.to_s
  end
end

