#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'yaml'


# Implements different merge policies for the configs.
module EasyAppHelper::Core::HashesMergePolicies
  # Performs a merge at the second level of hashes.
  # simple entries and arrays are overridden.
  def hashes_second_level_merge(h1, h2)
    h2.each do |key, v|
      if h1[key] and h1[key].is_a?(Hash)
        # Merges hashes
        h1[key].merge! h2[key]
      else
        # Overrides the rest
        h1[key] = h2[key] unless h2[key].nil?
      end
    end
    h1
  end

  # Uses the standard "merge!" method
  def simple_merge(h1, h2)
    h1.merge! h2
  end

  # Brutal override
  def override_merge(h1, h2)
    h1 = nil
    h1 = h2

  end
end

class EasyAppHelper::Core::Config < EasyAppHelper::Core::Base
end

require 'easy_app_helper/core/places'

class EasyAppHelper::Core::Config < EasyAppHelper::Core::Base
  ADMIN_CONFIG_FILENAME = EasyAppHelper.name

  include EasyAppHelper::Core::HashesMergePolicies

  # include paths specific to the OS
  include EasyAppHelper::Core::Config::Places.get_OS_module

  # Potential extensions a config file can have
  CONFIG_FILE_POSSIBLE_EXTENSIONS = %w(conf yml cfg yaml CFG YML YAML Yaml)


  attr_reader :system_config, :global_config, :user_config, :ad_hoc_config


  def load_config
    super
    unless script_filename.nil? or script_filename.empty?
      load_system_wide_config
      load_global_wide_config
      load_user_wide_config
      load_command_line_specified_config
    end
  end

  def add_cmd_line_options
    add_command_line_section('Configuration options') do |slop|
      slop.on 'config-file', 'Specify a config file.', :argument => true
      slop.on 'config-override', 'If specified override all other config.', :argument => false
    end
  end

  def to_hash
    merged_config = [:system, :global, :user].inject({}) do |temp_config, config_level|
      hashes_second_level_merge temp_config, internal_configs[config_level][:content]
    end
    if command_line_config[:'config-file']
      if command_line_config[:'config-override']
        override_merge merged_config, internal_configs[:command_line_specified][:content]
      else
        hashes_second_level_merge merged_config, internal_configs[:command_line_specified][:content]
      end

    end
    hashes_second_level_merge merged_config, command_line_config

  end

  def [](key)
    self.to_hash[key]
  end

  private

  def load_system_wide_config
    filename = find_file SYSTEM_CONFIG_POSSIBLE_PLACES, script_filename
    internal_configs[:system] = {content: load_config_file(filename), source: filename}
  end

  def  load_global_wide_config
    filename = find_file GLOBAL_CONFIG_POSSIBLE_PLACES, script_filename
    internal_configs[:global] = {content: load_config_file(filename), source: filename}
  end
  def load_user_wide_config
    filename = find_file USER_CONFIG_POSSIBLE_PLACES, script_filename
    internal_configs[:user] = {content: load_config_file(filename), source: filename}
  end
  def load_command_line_specified_config
    filename = internal_configs[:command_line][:content][:'config-file']
    internal_configs[:command_line_specified] = {content: load_config_file(filename), source: filename}
  end

  def load_config_file(conf_filename)
    conf = {}
    return conf if conf_filename.nil?

    begin
      logger.debug "Loading config file \"#{conf_filename}\""
      conf = Hash[YAML::load(open(conf_filename)).map { |k, v| [k.to_sym, v] }]
    rescue => e
      logger.error "Invalid config file \"#{conf_filename}\". Not respecting YAML syntax!\n#{e.message}"
    end
    conf
  end

  # Tries to find config files according to places (array) given and possible extensions
  def find_file(places, filename)
    places.each do |dir|
      CONFIG_FILE_POSSIBLE_EXTENSIONS.each do |ext|
        filename_with_path = dir + '/' + filename + '.' + ext
        if File.exists? filename_with_path
          return filename_with_path
        else
          logger.debug "Trying \"#{filename_with_path}\" as config file."
        end
      end
    end
    nil
  end
end
