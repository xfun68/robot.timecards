require_relative '../common'

require 'json'
require 'uri'
require 'net/http'

class Luosimao
  API_KEY = ''
  private_constant :API_KEY

  def send(mobile, content)
    url = URI.parse('https://sms-api.luosimao.com/v1/send.json')
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth 'api', API_KEY
    req.set_form_data({mobile: mobile, message: content})

    puts "#{mobile} #{content}"
    return if is_debug?

    res = Net::HTTP.start(url.host, url.port, use_ssl: (url.scheme == 'https')) do |http|
      http.request(req)
    end
    puts "#{res.code} #{res.class.name}"
    puts res.body
    result = JSON.parse res.body
    (result["error"] == 0) && (result["msg"] == "ok")
  end
end

