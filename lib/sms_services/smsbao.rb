require_relative '../common'

require 'uri'
require 'net/http'

class Smsbao
  def send(mobile, content)
    uri = make_uri(mobile, content)
    puts uri

    return if is_debug?

    res = Net::HTTP.get_response uri
    puts "#{res.code} #{res.class.name}"
    res.code.to_s == '200'
  end

  private

  def make_uri(mobile, content)
    uri = URI("http://www.smsbao.com/sms")
    params = {
      u: username,
      p: password,
      m: mobile,
      c: content
    }
    uri.query = URI.encode_www_form params
    uri
  end

  def username
    ''
  end

  def password
    ''
  end
end

