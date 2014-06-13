require_relative 'contact'
require_relative 'mail_box'

SIGNATURE = ''
SMS_SERVICE = 'yunpian' # [yunpian, luosimao, smsbao]

Admins = File.readlines('./data/admins.csv').map { |line| line.strip.split ',' }.map { |admin| Contact.new(admin[0], admin[1]) }

Mail.defaults do
  delivery_method :smtp,
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => 'thoughtworks.com',
    :user_name            => '',    # TO BE CONFIGURED
    :password             => '',    # TO BE CONFIGURED
    :authentication       => 'plain',
    :enable_starttls_auto => true

  retriever_method :pop3,
    :address    => "pop.gmail.com",
    :port       => 995,
    :user_name  => '',    # TO BE CONFIGURED
    :password   => '',    # TO BE CONFIGURED
    :enable_ssl => true
end

