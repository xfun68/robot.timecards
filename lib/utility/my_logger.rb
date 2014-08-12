require 'singleton'
require 'logger'

class MyLogger < Logger
  include Singleton

  LOG_FILE = File.open('debug.log', 'a')

  def initialize
    @logdev = Logger::LogDevice.new(LOG_FILE)
    @level = Logger::DEBUG
    super(@logdev)
  end

end