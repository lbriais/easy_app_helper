module EasyAppHelper
  module Scripts

    module Common

      def extra_parameters
        EasyAppHelper.config.command_line_layer.extra_parameters
      end

      def pre_process(object=self)
        safe_execution {add_script_options} if object.respond_to? :add_script_options

        # logging startup configuration
        logger.debug "Config layers ->\n#{config.detailed_layers_info}"
        logger.debug "Merged config -> #{config[].to_yaml}"
        # Displaying (and exiting) command line help
        if config[:help]
          puts display_help
          exit 0
        end
        object.check_config if object.respond_to? :check_config
        logger.info 'Application is starting...'
      end

      def safe_execution
        yield if block_given?
      rescue => e
        STDERR.puts "Program ended with message: '#{e.message}'."
        if config[:debug]
          logger.fatal "#{e.message}\nBacktrace:\n#{e.backtrace.join("\n\t")}"
        else
          STDERR.puts '  Use --debug option for more detail (see --help).'
        end
        exit 1
      end

    end

  end
end
