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
      Initialisation.modules
    end

    def xxxxxxxxxxxxxinstance

    end


    private
    ############################################################################
    module Initialisation

      def self.modules
        logger = EasyAppHelper::Core::Logger.instance
        self.core_modules(logger)

      ensure
        logger.set_app_config({})
      end


      def self.core_modules(logger)
        config = EasyAppHelper::Core::Config.new logger
        config.add_cmd_line_options
        config.script_filename = 'batch_audio_convert'
        config.load_config
        logger.debug config.internal_configs
        logger.debug config.to_hash
        puts config.help
      end
    end

  end
end
