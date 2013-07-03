################################################################################
# EasyAppHelper
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require 'logger'
require 'singleton'

# Official Ruby Logger re-opened to introduce a method to hand-over the temporary history from a temporary logger
# to the definitive one.
# TODO: Ensure only the messages that are above the current level are displayed when handing over to the definitive logger.
class Logger
  def handing_over_to(log)
    history = []
    history = @logdev.dev.history if @logdev.dev.respond_to? :history
    @logdev.close
    @logdev = LogDevice.new log
    history.each do |msg|
      @logdev.write msg if ENV['DEBUG_EASY_MODULES'] or (msg =~ /^[WE]/)
    end
  end
end

# This is the logger that will be used by the application and any class that include {EasyAppHelper} module. It is
# configured by the {EasyAppHelper::Core::Config Config} object, and provides a temporary logger until the config
# is fully loaded.
class EasyAppHelper::Core::Logger < Logger
  include Singleton


  def initialize
    @config = {}
    super(TempLogger.new)
    self.level = Severity::DEBUG
    debug "Temporary initialisation logger created..."
  end

  # Change the log level while keeping the config in sync.
  def level=(level)
    super
    @config[:'log-level'] = level
  end

  # Displays the message according to application verbosity and logs it as info.
  def puts_and_logs(msg)
    puts msg if @config[:verbose]
    info(msg)
  end

  # Reset the logger regarding the config provided
  def set_app_config(config)
    @config = config
    add_cmd_line_options
    @config.load_config
    debug "Config layers:\n#{@config.internal_configs.to_yaml}"
    debug "Merged config:\n#{@config.to_yaml}"
    if config[:debug]
      if config[:'log-file']
        handing_over_to config[:'log-file']
      elsif config[:"debug-on-err"]
        handing_over_to STDERR
      else
        handing_over_to STDOUT
      end
    else
      close
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

  # This class will act as a temporary logger, actually just keeping the history until the real
  # configuration for the logger is known. Then the history is displayed or not regarding the
  # definitive logger configuration.
  class TempLogger
    attr_reader :history

    def initialize
      @history = []
    end

    def write(data)
      return if closed?
      @history << data if @history
    end

    def close
      @closed = true
    end

    def opened?() not @closed ; end
    def closed?() @closed ; end
  end

end


