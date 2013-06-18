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


module EasyAppHelper::Base
  module ModuleManager

    def self.included(base) # :nodoc:
      # Initialisation.modules
      @logger = EasyAppHelper::Core::Logger.instance
      @config = EasyAppHelper::Core::Config.new @logger
      @logger.set_app_config(@config)
      @config.script_filename = 'batch_audio_convert'
      @logger.debug @config.to_hash
      @logger.debug "Hello WORLD" #  @config.internal_configs
    end

    def xxxxxxxxxxxxxinstance

    end


    private
    ############################################################################
    module Initialisation

      def self.modules
        logger = EasyAppHelper::Core::Logger.instance
        config = self.core_modules(logger)

        logger.set_app_config(config)
      end


      def self.core_modules(logger)
        config = EasyAppHelper::Core::Config.new logger
        config.script_filename = 'batch_audio_convert'
        logger.debug config.internal_configs
        logger.debug config.to_hash
        puts config.help
        config
      end
    end

  end
end
