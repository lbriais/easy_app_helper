module EasyAppHelper
  module Config

    module Initializer

      def self.build_config
        config = StackedConfig::Orchestrator.new
        EasyAppHelper::Config.set_compatibility_mode(config) if config[:easy_app_helper_compatibility_mode]
        config
      end

    end

  end
end
