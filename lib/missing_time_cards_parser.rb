require_relative './mail_actor'

class MissingTimeCardsParser
  def self.parse(mail)
    content = mail.to_s.gsub("=\r\n", "").gsub("\r\n", "")
    content.scan(/mailto:([^@]+@thoughtworks.com)/).flatten.uniq
  end
end

