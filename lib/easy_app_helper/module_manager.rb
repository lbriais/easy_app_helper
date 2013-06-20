################################################################################
# EasyAppHelper
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

module EasyAppHelper::Core

end

require 'easy_app_helper/core/logger'
require 'easy_app_helper/core/base'
require 'easy_app_helper/core/config'

# This module is in charge to mix in the helper methods into the target class/instance
module EasyAppHelper::ModuleManager

  def self.included(base)
    init_core_modules
    base.extend CoreClassMethods
    self.extend CoreClassMethods
  end


  # @return [EasyAppHelper::Core::Logger] The application logger
  def logger
    @@logger
  end

  # @return [EasyAppHelper::Core::Config] The application config
  def config
    @@config
  end

  # Convenient method that logs at info level, but also outputs the message to STDOUT if
  # verbose is set in the config.
  # @param [String] Message to be displayed
  def puts_and_logs(msg)
    @@logger.puts_and_logs msg
  end

  module CoreClassMethods

    # @return [EasyAppHelper::Core::Logger] The application logger
    def logger
      @@logger
    end

    # @return [EasyAppHelper::Core::Config] The application config
    def config
      @@config
    end

    # Convenient method that logs at info level, but also outputs the message to STDOUT if
    # verbose is set in the config.
    # @param [String] Message to be displayed
    def puts_and_logs(msg)
      @@logger.puts_and_logs msg
    end

  end

  include CoreClassMethods

  private

  def self.init_logger
    @@logger ||= EasyAppHelper::Core::Logger.instance
    @@logger
  end

  def self.init_config
    @@config ||= EasyAppHelper::Core::Config.new @@logger
    @@logger.set_app_config(@@config)
    @@config
  end

  def self.init_core_modules
    init_logger
    init_config
  end
end