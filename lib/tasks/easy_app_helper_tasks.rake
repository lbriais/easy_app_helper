require 'rubygems'
require 'bundler/setup'

require File.expand_path '../template_manager.rb', __FILE__

namespace :easy_app_helper do

  include EasyAppHelper::Tasks::TemplateManager

  desc 'create automatically a new executable in "bin" from a template. Default name is Gem name'
  task :create_executable do
    build_executable
  end

  desc 'Displays the template used.'
  task :show_template do
    puts get_template
  end

end

