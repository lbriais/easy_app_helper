################################################################################
#
# (c)2013 L.Briais
################################################################################

require 'logger'


# This module provides access to logger fully configured according to command line options
# or config files.
module EasyAppHelper::Logger
  MODULE_PRIORITY = 1

  include EasyAppHelper::Common

  # Provides access to a standard logger, fully configured according to command line options
  # or config files.
  attr_reader :logger

  # Build logger for the application. Depending on config may end-up up to nowhere 
  # (DEFAULT_LOGGER), STDOUT, STDERR or a file. See --help or EasyAppHelper::Config#help
  # for all options.
  def build_logger
    logger_type = DEFAULT_LOGGER
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
    end
    logger_type = STDERR if app_config[:"debug-on-err"]
    @logger = Logger.new(logger_type)
    app_config[:'log-level'] = DEFAULT_LOG_LEVEL if app_config[:'log-level'].nil?
    logger.level = app_config[:"log-level"]
    logger.error issue_report if issue_report
  end

  # Returns the current log_level.
  def log_level
    app_config[:"log-level"]
  end

  # Enables to hot-change the log level.
  def log_level=(level)
    app_config[:"log-level"] = level
    logger.level = level
  end


  def self.module_entry_point
    :build_logger
  end

  def self.add_cmd_line_options(slop_definition)
    slop_definition.separator "\n-- Debug and logging options ---------------------------------"
    slop_definition.on :debug, 'Run in debug mode.', :argument => false
    slop_definition.on 'debug-on-err', 'Run in debug mode with output to stderr.', :argument => false
    slop_definition.on 'log-level', "Log level from 0 to 5, default #{Logger::Severity::ERROR}.", :argument => true, :as => Integer
    slop_definition.on 'log-file', 'File to log to.', :argument => true
  end



  ################################################################################
  private


end
