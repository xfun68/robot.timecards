require_relative './lib/config'
require_relative './lib/mail_actor'
require_relative './lib/no_mail_actor'
require_relative './lib/time_cards_reminder'
require_relative './lib/update_template'
require_relative './lib/update_contact'
require_relative './lib/unknown_mail_actor'

Contact.load './data/contacts'

MailActor.create_by(MailBox.first).do

puts 'Done.'

