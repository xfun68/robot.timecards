require_relative './mail_actor'

class ContactUpdateParser
  attr_reader :contacts

  def parse(mail)
    match = (/@@@([^@]+)@@@/m.match(mail.body.decoded) || [])[1]
    lines = match.split("\n").select { |line| !line.empty? }.compact
    @contacts = lines.map do |name_mobile_pair|
      name, mobile = name_mobile_pair.split ' '
      Contact.create_from_name name, mobile
    end
  end
end

