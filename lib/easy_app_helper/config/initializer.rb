module EasyAppHelper
  module Config

    module Initializer
      def self.build_config
        config = StackedConfig::Orchestrator.new
        config.extend EasyAppHelper::Config::Wrapper
        config
      end
    end

  end
end
