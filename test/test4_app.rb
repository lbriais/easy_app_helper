#!/usr/bin/env ruby

require 'easy_app_helper'
#require 'your_module'

class MyApp
  include EasyAppHelper
  # include YourModule

  APP_NAME = "My super application"
  # SCRIPT_NAME = File.basename($0, '.*')
  VERSION = '0.0.1'
  DESCRIPTION = 'This application is a proof of concept for EasyAppHelper.'


  def initialize
    # Providing this data is optional
    config.describes_application(app_name: APP_NAME, app_version: VERSION, app_description: DESCRIPTION)
    add_cmd_line_options
  end

  def run
    if config[:help]
      puts config.help
      exit 0
    end
    puts_and_logs "Application is starting"
    check_config
    do_some_processing
  rescue => e
    puts "Program aborted with message: #{e.message}"
    logger.fatal "#{e.message}\nBacktrace:\n#{e.backtrace.join("\n\t")}" if config[:debug]
  end

  private

  def check_config
    puts_and_logs "Checking application parameters"
  end

  def add_cmd_line_options
    config.add_command_line_section do |slop|
      slop.on :u, :useless, 'Stupid option', :argument => false
      slop.on :anint, 'Stupid option with integer argument', :argument => true, :as => Integer
    end
  end

end


MyApp.new.run