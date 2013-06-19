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

  def handing_over_to(log)
    history = ""
    history = @logdev.dev.history if @logdev.dev.respond_to? :history
    @logdev.close
    @logdev = LogDevice.new log
    @logdev.write history if ENV['DEBUG_EASY_MODULES']
  end
end

class EasyAppHelper::Core::Logger < Logger
  include Singleton

  def initialize
    @config = {}
    super(TempLogger.new)
    self.level = Severity::DEBUG
    debug "Temporary initialisation logger created..."

  end

  # Enables to hot-change the log level.
  def level=(level)
    super
    @config[:'log-level'] = level
  end

  # Displays the message according to application verbosity and logs it as info.
  def puts_and_logs(msg)
    puts msg if @config[:verbose]
    info(msg)
  end

  def set_app_config(config)
    @config = config
    add_cmd_line_options
    @config.load_config
    debug "Config layers:\n#{@config.internal_configs.to_yaml}"
    debug "Merged config:\n#{@config.to_yaml}"
    if config[:'log-file']
      handing_over_to config[:'log-file']
    elsif config[:"debug-on-err"]
      handing_over_to STDERR
    else
      handing_over_to STDOUT
    end
    self.level = config[:'log-level'] ? config[:'log-level'] : Severity::WARN
    self
  end

  private

  def add_cmd_line_options
    @config.add_command_line_section('Debug and logging options') do |slop|
      slop.on :debug, 'Run in debug mode.', :argument => false
      slop.on 'debug-on-err', 'Run in debug mode with output to stderr.', :argument => false
      slop.on 'log-level', "Log level from 0 to 5, default #{Severity::WARN}.", :argument => true, :as => Integer
      slop.on 'log-file', 'File to log to.', :argument => true
    end
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


