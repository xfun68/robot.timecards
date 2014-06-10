require_relative '../common'

require 'json'
require 'uri'
require 'net/http'

class Yunpian
  API_KEY = ''
  private_constant :API_KEY

  def send(mobile, content)
    url = URI.parse('http://yunpian.com/v1/sms/send.json')
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({apikey: API_KEY, mobile: mobile, text: content})

    puts "#{mobile} #{content}"
    return if is_debug?

    res = Net::HTTP.start(url.host, url.port, use_ssl: (url.scheme == 'https')) do |http|
      http.request(req)
    end
    puts "#{res.code} #{res.class.name}"
    puts res.body
    result = JSON.parse res.body
    (result["code"] == 0) && (result["msg"] == "OK")
  end
end

