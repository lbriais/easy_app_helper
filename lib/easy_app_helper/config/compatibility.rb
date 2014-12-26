module EasyAppHelper
  module Config

    module Compatibility

      # For backward compatibility with EasyAppHelper v1.x
      def help
        command_line_help
      end

      def command_line_config
        command_line_layer.slop_definition.to_hash
      end

    end

    def self.set_compatibility_mode(config=EasyAppHelper.config)
      config.extend EasyAppHelper::Config::Compatibility
    end

  end
end