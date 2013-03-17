################################################################################
# EasyAppHelper 
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

# Config file format
require 'yaml'

# This module defines:
# - some basic command line options (see --help) with their underlying
#   mechanism.
# - A mechanism (based on Slop) to add your own command line options.
# - A generated inline help.
# - A complete configuration framework with system wide and user level
#   configuration files with consistent override mechanism including command
#   line options. Config files are in YAML but can have different extensions.
module EasyAppHelper::Config

  include EasyAppHelper::Common

  # Where could be stored system wide configuration
  self::SYSTEM_CONFIG_POSSIBLE_PLACES = ["/etc",
                                         "/usr/local/etc"]
  # Where could be stored user configuration
  self::USER_CONFIG_POSSIBLE_PLACES = ["#{ENV['HOME']}/.config"]
  
  # Potential extensions a config file can have
  self::CONFIG_FILE_POSSIBLE_EXTENSIONS = ['conf', 'yml', 'cfg', 'yaml', 'CFG', 'YML', 'YAML', 'Yaml']

  # File that contained the system wide config
  attr_reader :system_wide_config_file

  # File that contained the user defined config
  attr_reader :user_config_file

  # Loads the configuration files (system, user) and creates basic command line options.
  # This handles the 3 levels of configuration:
  # - System wide YAML config file
  # - User YAML config file
  # - Command line options
  #
  # Config files may define any type of structure supported by YAML.
  # The override policy is that, if an entry in the config is a hash and the next
  # level defines the same hash, they are merged.
  # For any other type (scalar, array), the overrider... overrides ;)
  #
  # Config files can be at different places and have different extensions (see
  # arrays at the begining). They have the same base name as the script_filename.
  def self.provides_config(script_filename, app_name, app_description, app_version) 
    load_system_wide_config script_filename
    load_user_config script_filename
  end

  # If the option --config-file has been specified, it will be loaded and override
  # current configuration according to rules
  def load_custom_config
    return unless app_config[:'config-file']
    begin
      @app_config =  app_config,  EasyAppHelper::Config.load_config_file(app_config[:'config-file'])
    rescue => e
      err_msg = "Problem with \"#{app_config[:'config-file']}\" config file!\n#{e.message}\nIgnoring..."
      logger.error err_msg
    end
  end

  private

  # Reads config from system config file and merges with config provided in input.
  def self.load_system_wide_config(script_filename)
    load_config_file find_file SYSTEM_CONFIG_POSSIBLE_PLACES, script_filename
  end

  # Reads config from user config file and merges with config provided in input.
  def self.load_user_config(script_filename)
    load_config_file find_file USER_CONFIG_POSSIBLE_PLACES, script_filename
  end

  def self.add_cmd_line_options(slop_definition)
    slop_definition.separator "\n-- Configuration options -------------------------------------"
    slop_definition.on 'config-file', 'Specify a config file.', :argument => true
    slop_definition.on 'override-other-config', 'Does the specified config file override other config files.', :argument => false
  end

  def self.module_entry_point
    :load_custom_config
  end


  ################################################################################
  private 

  def self.load_config_file(conf_filename)
    return {} if conf_filename.nil? 
    # A file exists
    Hash[YAML::load(open(conf_filename)).map { |k, v| [k.to_sym, v] }]
  end

  # Tries to find config files according to places (array) given and possible extensions
  def self.find_file(places, filename)
    places.each do |dir|
      CONFIG_FILE_POSSIBLE_EXTENSIONS.each do |ext|
        filename_with_path = dir + '/' + filename + '.' + ext
        if File.exists? filename_with_path
          return filename_with_path
        end
      end
    end
    nil
  end


end
