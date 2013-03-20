################################################################################
# EasyAppHelper 
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require 'logger'


# This module provides access to logger(Logger) fully configured according to command line options
# or config files.
#
# It will replace the stupid EasyAppHelper::Common::DummyLogger if the
# module is included.
#
# It brings as well some command line options to manipulate debug.
# See --help
module EasyAppHelper::Logger

  # This module has the highest priority in order to be processed the first by
  # the framework and therefore give a chance to other modules to use it to log.
  MODULE_PRIORITY = 1

  include EasyAppHelper::Common


  # Returns the current log_level.
  def log_level
    app_config[:"log-level"]
  end

  # Enables to hot-change the log level.
  def log_level=(level)
    app_config[:"log-level"] = level
    logger.level = level
  end


  # Build logger for the application. Depending on config may end-up up to nowhere 
  # (by default), STDOUT, STDERR or a file. See --help or EasyAppHelper::Config#help
  # for all options.
  def build_logger
    @logger = EasyAppHelper::Common::DummyLogger.instance
    issue_report = nil
    if app_config[:debug]
      unless app_config[:"log-file"].nil?
        begin
          if File.exists? app_config[:"log-file"]
            logger_type = File.open(app_config[:"log-file"], File::WRONLY | File::APPEND)
          else
            logger_type = File.open(app_config[:"log-file"], File::WRONLY | File::CREAT)
          end
        rescue Exception => e
          logger_type = STDOUT
          issue_report = e.message
        end
      else
        logger_type =  STDOUT
      end
      logger_type = STDERR if app_config[:"debug-on-err"]
      @logger = Logger.new(logger_type)
    end
    app_config[:'log-level'] = DEFAULT_LOG_LEVEL if app_config[:'log-level'].nil?
    logger.level = app_config[:"log-level"]
    logger.error issue_report if issue_report
    logger.debug "Logger is created."
  end


end


module EasyAppHelper::Logger::Instanciator
  extend EasyAppHelper::Common::Instanciator

  # Default module priority
  MODULE_PRIORITY = 1

  # Adds some command line options for this module.
  # - +--debug+
  # - +--debug-on-err+ to have the debugging going to STDERR. Should be used on top of 
  #   --debug.
  # - +--log-file+ +filename+ To log to a specific file. 
  # - +--log-level+ +0-5+ Log level according to Logger::Severity
  def self.add_cmd_line_options(app, slop_definition)
    slop_definition.separator "\n-- Debug and logging options ---------------------------------"
    slop_definition.on :debug, 'Run in debug mode.', :argument => false
    slop_definition.on 'debug-on-err', 'Run in debug mode with output to stderr.', :argument => false
    slop_definition.on 'log-level', "Log level from 0 to 5, default #{EasyAppHelper::Common::DEFAULT_LOG_LEVEL}.", :argument => true, :as => Integer
    slop_definition.on 'log-file', 'File to log to.', :argument => true
  end

  # Creates the application logger
  def self.post_config_action(app)
    app.build_logger
  end

end
