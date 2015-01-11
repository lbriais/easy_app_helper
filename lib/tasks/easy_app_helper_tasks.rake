require 'rubygems'
require 'bundler/setup'

require File.expand_path '../template_manager.rb', __FILE__

namespace :easy_app_helper do

  include EasyAppHelper::Tasks::TemplateManager

  desc 'create automatically a new executable in "bin" from a template. Default name is Gem name'
  task :create_executable, [:executable_name] do |tsk, args|
    script_content = build_executable args[:executable_name]
    bin_dir = check_bin_dir
    script_name = File.join bin_dir, executable_name
    if File.exists? script_name
      STDERR.puts "File '#{script_name}' already exists !\n -> Aborted."
      next
    end
    File.write script_name, script_content
    FileUtils.chmod 'u=wrx,go=rx', script_name
    puts "File '#{script_name}' created with execution rights.\n -> Try: \"bundle exec '#{script_name}' --help\" to test it."
  end

  desc 'Displays the template used.'
  task :show_template do
    puts get_template
  end

end

