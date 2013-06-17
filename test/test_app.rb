#!/usr/bin/env ruby


require 'easy_app_helper'


class TestApp
  include EasyAppHelper

  def add_specifc_command_line_options(opt)
    opt.on :s, :stupid, 'Stupid option', :argument => false
    opt.on :i, :int, 'Stupid option with integer argument', :argument => true, :as => Integer
  end

end

t = TestApp.new
p "Instance #{t.methods.grep /xxxxxx/}"
p "Class #{t.class.methods.grep /xxxxxxxx/}"
