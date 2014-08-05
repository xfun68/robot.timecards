require 'nokogiri'
require 'date'
require_relative './mail_actor'


class TimeCardHoursParser
  attr_reader :records
  @@office = String.new
  @@email = String.new

  def initialize
    @records = Array.new
  end

  def parse(mail)
    decodedMail = mail.body.decoded.to_lf.gsub('=3D', '%3D').gsub("=\n", '').gsub('%3D', '=')
    doc = Nokogiri::HTML(decodedMail)

    table = doc.css('table.reportTable.matrixReportTable')
    weekTitles = table.xpath('tr/th/text()')
    @weeks = weekTitles.map { |t| t.content }.select { |t| Date.strptime(t, "%Y-%m-%d") rescue false }

    titles = table.xpath('tr[2]/th/strong/text() | tr[2]/th/text()') # all the titles
    @startDateIndex = titles.map {|t| t.content}.index('Resource: Start Date') + 2
    @lastDateIndex = titles.map {|t| t.content}.index('Resource: Last Date')
    @lastDateIndex + 2 unless @lastDateIndex.nil?

    data = table.xpath('tr')
    data.each do |row|
      parse_record(row)
    end

    @records = @records.select do |record|
      record[:illegal_hours_weeks] = record[:illegal_hours_weeks].select do |week, timecard_hours|
        start_date = Date.parse(record[:startDate])
        last_date = Date.parse(record[:lastDate]) unless record[:last_date].nil?
        week_first_work_day = Date.parse(week).prev_day(6)
        week_last_work_day = Date.parse(week).prev_day(2)

        actual_week_start_work_day = start_date < week_first_work_day ? week_first_work_day : start_date
        actual_week_last_work_day = week_last_work_day
        unless last_date.nil?
          actual_week_last_work_day = last_date > week_last_work_day ? week_last_work_day : last_date
        end

        work_day_this_week = actual_week_last_work_day - actual_week_start_work_day + 1

        work_day_this_week*8 > timecard_hours
      end

      record[:illegal_hours_weeks].length > 0
    end
  end

  private
  def parse_record(row)
    return nil if row.at_xpath('td[2]/a/text()').nil? && row.at_xpath("td[#{@startDateIndex}]/text()").nil?

    if !row.at_xpath('td[2]/a/text()').nil?
      record = {}

      email = row.at_xpath('td[2]/a/text()').content if !row.at_xpath('td[2]/a/text()').nil?
      @@email = email if !email.nil? && email != @@email
      record[:email] = @@email


      record[:illegal_hours_weeks] = {}

      office = row.at_xpath("td[1]/a/text()").content.to_s if !row.at_xpath("td[1]/a/text()").nil?
      @@office = office if !office.nil? && office != @@office
      record[:office] = @@office

      (0...@weeks.length).each do |i|
        hours = row.at_xpath("td[#{3+i}]/table/tr/td/text()").content.to_f
        record[:illegal_hours_weeks] = record[:illegal_hours_weeks].merge({@weeks[i] => hours}) if hours < 40.0 && hours > 0
      end

      if record.nil? || record[:illegal_hours_weeks].empty? || record[:illegal_hours_weeks].blank?
        return nil
      else
        @records.push(record)
      end

    end

    if !row.at_xpath("td[#{@startDateIndex}]/text()").nil?
      tmpRecord = @records.find{ |r| r[:email] == @@email }
      unless tmpRecord.nil?
        tmpRecord[:startDate] = row.at_xpath("td[#{@startDateIndex}]/text()").content
      end
    end

    unless @lastDateIndex.nil?
      if !row.at_xpath("td[#{@lastDateIndex}]/text()").nil?
        tmpRecord = @records.find{ |r| r[:email] == @@email }
        unless tmpRecord.nil?
          tmpRecord[:lastDate] = row.at_xpath("td[#{@lastDateIndex}]/text()").content
        end
      end
    end
  end
end

