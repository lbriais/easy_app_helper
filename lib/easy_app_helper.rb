require 'stacked_config'

require 'logger'

require 'easy_app_helper/version'
require 'easy_app_helper/config/initializer'
require 'easy_app_helper/config/wrapper'
require 'easy_app_helper/config'
require 'easy_app_helper/logger/initializer'
require 'easy_app_helper/logger/wrapper'
require 'easy_app_helper/managed_logger'

module EasyAppHelper

  def puts_and_logs(*args)
    logger.puts_and_logs *args
  end

  def safely_exec(message, *args, &block)
    config.safely_exec message, *args, &block
  end

end