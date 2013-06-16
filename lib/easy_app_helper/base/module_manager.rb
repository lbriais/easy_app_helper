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
        self.core_modules
      end


      def self.core_modules
        logger = EasyAppHelper::Core::Logger.instance
        base  = EasyAppHelper::Core::Base.new
        # config = EasyAppHelper::Core::Base.new
        logger.set_app_config({})
      end
    end

  end
end
