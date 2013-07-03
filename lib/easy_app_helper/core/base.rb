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

  attr_reader :script_filename, :app_name, :app_version, :app_description, :internal_configs, :logger

  def initialize(logger)
    @app_name = @app_version = @app_description = ""
    @script_filename = File.basename $0, '.*'
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
  def script_filename=(filename)
    @script_filename = filename
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

  # helper to add in one command any of the four base properties used
  # by the logger and the config objects.
  # @param [String] app_name
  # @param [String] script_filename
  # @param [String] app_version
  # @param [String] app_description
  def describes_application(app_name: nil, script_filename: nil, app_version: nil, app_description: nil)
    self.app_name = app_name unless app_name.nil?
    self.app_version = app_version unless app_version.nil?
    self.app_description = app_description unless app_description.nil?
    self.script_filename = script_filename unless script_filename.nil?
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

  def safely_exec(message, *args)
    raise "No block given" unless block_given?
    if self[:simulate]
      logger.puts_and_logs "SIMULATING: #{message}" unless message.nil?
    else
      logger.puts_and_logs message
      yield(*args)
    end
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
    "\nUsage: #{script_filename} [options]\n#{app_name} Version: #{app_version}\n\n#{app_description}"
  end

end