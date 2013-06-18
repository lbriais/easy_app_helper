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
    end

    def xxxxxxxxxxxxxinstance

    end


    private


  end
end
