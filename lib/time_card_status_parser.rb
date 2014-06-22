require 'nokogiri'
require_relative './mail_actor'

class TimeCardStatusParser
  def self.parse(mail)
    doc = Nokogiri::HTML(mail.body.decoded)
    table=doc.css('table.reportTable.tabularReportTable')
    cities = table.xpath('tr/td/span/a/text()').map {|cell| cell.content }
    numbers = table.xpath('tr/td/strong/span/text()').map {|cell| cell.content }.map {|text| text.scan(/\((\d+)/).flatten.first.to_i}
    numbers.shift # the first number is total count, discard it
    result = {}
    cities.each_index { |i| result[cities[i]] = numbers[i] }
    result
  end
end

