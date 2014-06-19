require 'nokogiri'
require_relative './mail_actor'


class TimeCardHoursParser
  attr_reader :records

  def parse(mail)
    doc = Nokogiri::HTML(mail.body.decoded)
    table = doc.css('table.reportTable.matrixReportTable')
    title = table.xpath('tr/th/text()')
    @weeks = title.map { |t| t.content }.select { |t| Date.strptime(t, "%Y-%m-%d") rescue false }
    data = table.xpath('tr')
    @records = data.map { |row| parse_record(row) }.compact.select { |rec| !rec[:illegal_hours_weeks].empty? }
  end

  private

  def parse_record(row)
    return nil if row.at_xpath('td[2]/a/text()').nil?
    record = {}
    record[:email] = row.at_xpath('td[2]/a/text()').content
    record[:illegal_hours_weeks] = []
    (0...@weeks.length).each do |i|
      hours = row.at_xpath("td[#{3+i}]/table/tr/td/text()").content.to_f
      record[:illegal_hours_weeks] << @weeks[i] if hours < 40.0 && hours > 0
    end
    record
  end

end

