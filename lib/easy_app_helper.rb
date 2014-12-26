require 'stacked_config'

require 'logger'

require 'easy_app_helper/version'
require 'easy_app_helper/config/compatibility'
require 'easy_app_helper/config/initializer'
require 'easy_app_helper/config'
require 'easy_app_helper/logger/initializer'
require 'easy_app_helper/logger/wrapper'
require 'easy_app_helper/managed_logger'

module EasyAppHelper

  def puts_and_logs(*args)
    logger.puts_and_logs *args
  end

  def safely_exec(message, *args, &block)
    if self[:simulate]
      puts_and_logs "SIMULATING: #{message}" unless message.nil?
    else
      puts_and_logs message
      yield(*args)
    end
  end


end