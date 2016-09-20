require 'stacked_config'

require 'logger'

require 'easy_app_helper/version'
require 'easy_app_helper/config/compatibility'
require 'easy_app_helper/config/initializer'
require 'easy_app_helper/config'
require 'easy_app_helper/logger/initializer'
require 'easy_app_helper/logger/wrapper'
require 'easy_app_helper/managed_logger'

require 'easy_app_helper/processes'
require 'easy_app_helper/input'


module EasyAppHelper

  def puts_and_logs(*args)
    logger.puts_and_logs *args
  end

  def safely_exec_code(message, *args, &block)
    if self.config[:simulate]
      puts_and_logs "[SIMULATION MODE]: #{message}" unless message.nil?
    else
      puts_and_logs message
      block.call *args
    end
  end

  def safely_exec_command(message, command, show_output = false, log_output = true, &log_processor)
    message = command if message.nil? or message.empty?
    safely_exec_code message, command, show_output, log_output do |command, show_output, log_output|
      process = EasyAppHelper::Processes::Base.new command
      process.show_output = show_output
      process.log_output = log_output
      process.execute &log_processor
      process
    end
  end


end