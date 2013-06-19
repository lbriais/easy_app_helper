#!/usr/bin/env ruby


require 'easy_app_helper'


class Pipo
  include EasyAppHelper


  def toto
    puts_and_logs "Et bim"
    puts_and_logs config.to_hash
  end
end



class TestApp
  include EasyAppHelper

  def initialize
    #config.script_filename = File.basename $0
    #config.app_name = 'Test application'
    #config.app_description = 'Best app to test the framework'
    #config.app_version = '1.0.0'
    puts_and_logs "Hello World"
    p = Pipo.new.toto
    config.script_filename = 'batch_audio_convert'
    puts config.to_hash
    config.internal_configs.each do |layer|
      puts layer
    end
    puts config[:destination]

    # puts config.help
  end

  def add_specifc_command_line_options(opt)
    opt.on :s, :stupid, 'Stupid option', :argument => false
    opt.on :i, :int, 'Stupid option with integer argument', :argument => true, :as => Integer
  end

end

t = TestApp.new
