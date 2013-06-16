#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'logger'
require 'singleton'


class Logger
  protected
  attr_accessor :logdev
end

class EasyAppHelper::Core::Logger < Logger
  include Singleton

  def initialize
    @config = {}
    if ENV['DEBUG_EASY_MODULES']
      super(TempLogger.new)
      self.level = Severity::DEBUG
      debug "Temporary initialisation logger created..."
    end
  end

  # Enables to hot-change the log level.
  def log_level=(level)
    @config[:'log-level'] = level
    self.level = level
  end

  # Displays the message according to application verbosity and logs it as info.
  def puts_and_logs(msg)
    puts msg if @config[:verbose]
    info(msg)
  end

  def set_app_config(config)
    @config = config
    history = logdev.dev.is_a?(TempLogger) ? logdev.dev.history : ""
    if config[:'log-file']
      logdev = config[:'log-file']
    elsif config[:"debug-on-err"]
      logdev = STDERR
    else
      logdev = STDOUT
    end
    logdev.write history unless history.empty?
    self
  end

  class TempLogger
    attr_reader :history

    def initialize
      @history = ""
    end

    def write(data)
      @history << data if @history
    end

    def close

    end
  end

end


