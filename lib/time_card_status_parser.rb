require 'nokogiri'
require_relative './mail_actor'

class TimeCardStatusParser
  def self.parse(mail)
    doc = Nokogiri::HTML(mail.body.decoded)
    if regionFilter = mail.body.match(/Resource: Region.*<span  class="filterValue">(.*)<\/span>/)
      regions = regionFilter.captures
    end

    result = {}
    regions[0].to_s.split(',').each do |city|
      result[city.to_s.capitalize.gsub("&#39;", "'")] = 0 # Xi&#39;an ==> Xi'an
    end

    table=doc.css('table.reportTable.tabularReportTable')
    missingTimeCardCities = table.xpath('tr/td/span/a/text()').map {|cell| cell.content }
    numbers = table.xpath('tr/td/strong/span/text()').map {|cell| cell.content }.map {|text| text.scan(/\((\d+)/).flatten.first.to_i}
    numbers.shift # the first number is total count, discard it

    missingTimeCardCities.each_index { |i| result[missingTimeCardCities[i]] = numbers[i] }
    result
  end
end

