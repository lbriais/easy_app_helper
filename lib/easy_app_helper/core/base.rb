#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'slop'

class EasyAppHelper::Core::Base
  CHANGED_BY_CODE = 'Changed by code'

  attr_reader :script_filename, :app_name, :app_version, :app_description, :internal_configs, :logger

  def initialize(logger)
    @script_filename = @app_name = @app_version = @app_description = ""
    @internal_configs = {modified: {content: {}, source: CHANGED_BY_CODE}}
    @logger = logger
    @slop_definition = Slop.new
    build_command_line_options
  end

  def help
    @slop_definition.to_s
  end

  def script_filename=(name)
    @script_filename = name
    @slop_definition.banner = build_banner
  end
  def app_name=(name)
    @app_name = name
    @slop_definition.banner = build_banner
  end
  def app_version=(version)
    @app_version = version
    @slop_definition.banner = build_banner
  end
  def app_description=(description)
    @app_description = description
    @slop_definition.banner = build_banner
  end

  def command_line_config
    @slop_definition.parse
    @slop_definition.to_hash
  end

  def add_command_line_section(title='script specific')
    raise "Incorrect usage" unless block_given?
    @slop_definition.separator build_separator(title)
    yield @slop_definition
  end

  def load_config
    internal_configs[:command_line] = {content: command_line_config, source: 'Command line'}
  end

  def []=(key,value)
    internal_configs[:modified][:content][key] = value
  end

  def reset
    internal_configs[:modified] = {content: {}, source: CHANGED_BY_CODE}
  end

  def layers
    internal_configs.keys
  end

  private

  def build_separator(title)
    "-- #{title} ".ljust 80, '-'
  end

  # Builds common used command line options
  def build_command_line_options # (script_filename, app_name, app_description, app_version)
                                 # Default options
    add_command_line_section('Generic options') do |slop|
      slop.on :auto, 'Auto mode. Bypasses questions to user.', :argument => false
      slop.on :simulate, 'Do not perform the actual underlying actions.', :argument => false
      slop.on :v, :verbose, 'Enable verbose mode.', :argument => false
      slop.on :h, :help, 'Displays this help.', :argument => false
    end
  end

  def build_banner
    "\nUsage: #{script_filename} [options]\n#{app_name} Version: #{app_version}\n\n#{app_description}"
  end

end