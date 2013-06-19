#!/usr/bin/env ruby


require 'easy_app_helper'
EasyAppHelper.logger.level = 0
EasyAppHelper.puts_and_logs "Groovy baby !"
EasyAppHelper.config[:zboubi] = "Hi shared"

class A
  include EasyAppHelper

  def echo
    puts_and_logs config[:zboubi]
  end
end

A.new.echo
EasyAppHelper.puts_and_logs EasyAppHelper.config[:zboubi]

include EasyAppHelper
puts_and_logs "ZBOUBI: #{config[:zboubi]}"
config.reset
puts_and_logs "ZBOUBI2: #{config[:zboubi]}"

