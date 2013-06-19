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

    def self.included(base)
      @@logger ||= EasyAppHelper::Core::Logger.instance
      @@config ||= EasyAppHelper::Core::Config.new @@logger
      @@logger.set_app_config(@@config)
      base.extend CoreClassMethods
    end

    def logger
      @@logger
    end

    def config
      @@config
    end

    def puts_and_logs(msg)
      @@logger.puts_and_logs msg
    end

    module CoreClassMethods

      def logger
        @@logger
      end

      def config
        @@config
      end
    end

  end
end