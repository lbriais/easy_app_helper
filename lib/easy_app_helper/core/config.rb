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

  include EasyAppHelper::Core::HashesMergePolicies

  # include paths specific to the OS
  include EasyAppHelper::Core::Config::Places.get_OS_module
  ADMIN_CONFIG_FILENAME = EasyAppHelper.name


  # Potential extensions a config file can have
  CONFIG_FILE_POSSIBLE_EXTENSIONS = %w(conf yml cfg yaml CFG YML YAML Yaml)

  def initialize(logger)
    super
    add_cmd_line_options
    load_config
  end

  def script_filename=(name)
    super
    [:system, :global, :user, :specific_file].each do |scope|
      internal_configs[scope] = {content: {}, source: nil, origin: nil}
    end
    force_reload
  end

  def load_config(force=false)
    super()
    load_system_wide_config force
    load_global_wide_config force
    load_user_wide_config force
    load_specific_file_config force
  end

  def force_reload
    load_config true
  end


  def to_hash
    merged_config = [:system, :global, :user].inject({}) do |temp_config, config_level|
      hashes_second_level_merge temp_config, internal_configs[config_level][:content]
    end
    if command_line_config[:'config-file']
      if command_line_config[:'config-override']
        override_merge merged_config, internal_configs[:specific_file][:content]
      else
        hashes_second_level_merge merged_config, internal_configs[:specific_file][:content]
      end

    end
    hashes_second_level_merge merged_config, command_line_config
    hashes_second_level_merge merged_config, internal_configs[:modified][:content]
  end

  def [](key)
    self.to_hash[key]
  end

  def to_yaml
    to_hash.to_yaml
  end

  #############################################################################
  private

  def add_cmd_line_options
    add_command_line_section('Configuration options') do |slop|
      slop.on 'config-file', 'Specify a config file.', :argument => true
      slop.on 'config-override', 'If specified override all other config.', :argument => false
    end
  end

  def load_system_wide_config(force=false)
    unless_cached(:system, SYSTEM_CONFIG_POSSIBLE_PLACES, ADMIN_CONFIG_FILENAME, force) do |scope, places, filename|
      filename = find_file places, filename
      internal_configs[scope] = {content: load_config_file(filename), source: filename, origin: script_filename}
    end
  end

  def  load_global_wide_config(force=false)
    unless_cached(:global, GLOBAL_CONFIG_POSSIBLE_PLACES, script_filename, force) do |scope, places, filename|
      filename = find_file places, filename
      internal_configs[scope] = {content: load_config_file(filename), source: filename, origin: script_filename}
    end
  end
  def load_user_wide_config(force=false)
    unless_cached(:user, USER_CONFIG_POSSIBLE_PLACES, script_filename, force) do |scope, places, filename|
      filename = find_file places, filename
      internal_configs[scope] = {content: load_config_file(filename), source: filename, origin: script_filename}
    end
  end
  def load_specific_file_config(force=false)
    unless_cached(:specific_file, nil, internal_configs[:command_line][:content][:'config-file'], force) do |scope, places, filename|
      internal_configs[scope] = {content: load_config_file(filename), source: filename, origin: script_filename}
    end
  end

  def load_config_file(conf_filename)
    conf = {}
    return conf if conf_filename.nil?

    begin
      logger.debug "Loading config file \"#{conf_filename}\""
      conf = Hash[YAML::load(open(conf_filename)).map { |k, v| [k.to_sym, v] }]
    rescue => e
      logger.error "Invalid config file \"#{conf_filename}\". Skipping as not respecting YAML syntax!\n#{e.message}"
    end
    conf
  end

  def unless_cached(layer, places, filename, forced)
    cached = false
    if internal_configs[layer]
      cached = true unless internal_configs[layer][:origin] == filename
    end
    if forced or not cached
      yield layer, places, filename
    end

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
