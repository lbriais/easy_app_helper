################################################################################
# EasyAppHelper
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require 'slop'

# This class is the base class for the {EasyAppHelper::Core::Config config} object.
# It handles the internal_configs hash that actually contains all configurations read from
# various sources: command line, config files etc...

class EasyAppHelper::Core::Base
  CHANGED_BY_CODE = 'Changed by code'

  attr_reader :config_filename, :app_name, :app_version, :app_description, :internal_configs, :logger

  def initialize(logger)
    @config_filename = @app_name = @app_version = @app_description = ""
    @internal_configs = {modified: {content: {}, source: CHANGED_BY_CODE}}
    @logger = logger
    @slop_definition = Slop.new
    build_command_line_options
  end


  # @return [String] The formatted command line help
  def help
    @slop_definition.to_s
  end

  # sets the filename while maintaining the slop definition upto date
  # @param [String] filename
  def config_filename=(filename)
    @config_filename = filename
    @slop_definition.banner = build_banner
  end
  # sets the application name used for logging while maintaining the slop definition upto date
  # @param [String] fname
  def app_name=(name)
    @app_name = name
    @slop_definition.banner = build_banner
  end
  # sets the version while maintaining the slop definition upto date
  # @param [String] version
  def app_version=(version)
    @app_version = version
    @slop_definition.banner = build_banner
  end
  # sets the filename while maintaining the slop definition upto date
  # @param [String] description
  def app_description=(description)
    @app_description = description
    @slop_definition.banner = build_banner
  end


  # @return [Hash] This hash built from slop definition correspond to the :command_line layer of internal_configs
  def command_line_config
    @slop_definition.parse
    @slop_definition.to_hash
  end

  # Yields a slop definition to modify the command line parameters
  # @param [String] title used to insert a slop separator
  def add_command_line_section(title='Script specific')
    raise "Incorrect usage" unless block_given?
    @slop_definition.separator build_separator(title)
    yield @slop_definition
  end

  # Sets the :command_line layer of internal_configs to the computed {#command_line_config}
  def load_config
    internal_configs[:command_line] = {content: command_line_config, source: 'Command line'}
  end

  # Any modification done to the config is in fact stored in the :modified layer of internal_configs
  # @param [String] key
  # @param [String] value
  def []=(key,value)
    internal_configs[:modified][:content][key] = value
  end

  # Reset the :modified layer of internal_configs rolling back any change done to the config
  def reset
    internal_configs[:modified] = {content: {}, source: CHANGED_BY_CODE}
  end


  # @return [Array] List of layers
  def layers
    internal_configs.keys
  end

  private

  def build_separator(title)
    "-- #{title} ".ljust 80, '-'
  end

  # Builds common used command line options
  def build_command_line_options
    add_command_line_section('Generic options') do |slop|
      slop.on :auto, 'Auto mode. Bypasses questions to user.', :argument => false
      slop.on :simulate, 'Do not perform the actual underlying actions.', :argument => false
      slop.on :v, :verbose, 'Enable verbose mode.', :argument => false
      slop.on :h, :help, 'Displays this help.', :argument => false
    end
  end

  def build_banner
    "\nUsage: #{File.basename $0} [options]\n#{app_name} Version: #{app_version}\n\n#{app_description}"
  end

end