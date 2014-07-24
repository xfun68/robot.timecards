require 'nokogiri'
require 'date'
require_relative './mail_actor'


class TimeCardHoursParser
  attr_reader :records

  def parse(mail)
    doc = Nokogiri::HTML(mail.body.decoded)
    table = doc.css('table.reportTable.matrixReportTable')
    title = table.xpath('tr/th/text()')
    @weeks = title.map { |t| t.content }.select { |t| Date.strptime(t, "%Y-%m-%d") rescue false }
    data = table.xpath('tr')
    @records = data.map { |row| parse_record(row) }.compact.select { |rec| !rec[:illegal_hours_weeks].empty? && !rec[:is_new] && !rec[:is_dismiss] }
  end

  private

  def parse_record(row)
    return nil if row.at_xpath('td[2]/a/text()').nil?
    record = {}
    record[:email] = row.at_xpath('td[2]/a/text()').content
    record[:illegal_hours_weeks] = {}
    record[:office] = row.at_xpath("td[1]/a/text()").content.to_s
    (0...@weeks.length).each do |i|
      hours = row.at_xpath("td[#{3+i}]/table/tr/td/text()").content.to_f
      start_time = row.at_xpath("td[#{3+@weeks.length}]/table/tr/td/text()").content.to_s
      end_time = row.at_xpath("td[#{4+@weeks.length}]/table/tr/td/text()").content.to_s
      record[:illegal_hours_weeks] = record[:illegal_hours_weeks].merge({@weeks[i] => hours}) if hours < 40.0 && hours > 0
      record[:is_new] = employed_in_week(start_time, @weeks[i])
      record[:is_dismiss] = !end_time.blank? && Date.parse(end_time) < Date.parse(@weeks[i]).prev_day(2)
    end
    record
  end

  def employed_in_week(day, last_day_of_week)
    current = Date.parse day
    last_day = Date.parse last_day_of_week
    current < last_day && current > last_day.prev_day(6)
  end

end

