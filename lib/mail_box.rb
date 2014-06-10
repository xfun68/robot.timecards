require_relative 'common'
require 'mail'

class MailBox
  def self.first
    return Mail.read('./samples/email.eml') if is_debug?
    [Mail.first].flatten.first
  end
end

