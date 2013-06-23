#!/usr/bin/env ruby

require 'easy_app_helper'

class MyApp
  include EasyAppHelper

  APP_NAME = "My super application"
  # SCRIPT_NAME = File.basename($0, '.*')
  VERSION = '0.0.1'
  DESCRIPTION = 'This application is a proof of concept for EasyAppHelper.'


  def initialize
    # Providing this data is optional
    config.describes_application(app_name: APP_NAME, app_version: VERSION, app_description: DESCRIPTION)
  end


  def run
    if config[:help]
      puts config.help
      exit 0
    end
    puts_and_logs "Application is starting"
    do_some_processing
  end

  def do_some_processing
    puts_and_logs "Starting some heavy processing"
  end

end


MyApp.new.run