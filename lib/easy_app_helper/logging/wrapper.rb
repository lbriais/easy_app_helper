module EasyAppHelper
  module Logging

    module Wrapper
      def puts_and_logs(msg)
        puts msg if EasyAppHelper.config[:verbose]
        info(msg)
      end
    end

    def logger=(logger)
      logger.extend EasyAppHelper::Logger::Wrapper
    end

  end
end