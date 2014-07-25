require_relative 'common'
require_relative 'sms_services/yunpian'
require_relative 'sms_services/luosimao'
require_relative 'sms_services/smsbao'

class Sms
  def initialize(service_name)
    @service = Luosimao.new
    if (service_name == 'smsbao')
      @service = Smsbao.new
    elsif (service_name == 'yunpian')
      @service = Yunpian.new
    end
  end

  def send(mobile, content)
    # puts "#{mobile} #{content + SIGNATURE}"; true
    if is_debug?
      puts "#{mobile} -- #{content} -- #{SIGNATURE}"
    else
      @service.send mobile, content + SIGNATURE
    end
  end
end

