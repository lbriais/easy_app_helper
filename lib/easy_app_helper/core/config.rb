################################################################################
# EasyAppHelper
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require 'yaml'
# This is the class that will handle the configuration.
# Configuration is read from different sources:
# - config files (system, global, user, specified on the command line)
# - command line options
# - any extra config you provide programmatically
#
# == Config files:
# system, global, and user config files are searched in the file system according to
# complex rules. First the place where to search them depends on the OS
# (Provided by {EasyAppHelper::Core::Config::Places}), and then multiple file extensions are
# tested ({EasyAppHelper::Core::Config::CONFIG_FILE_POSSIBLE_EXTENSIONS}). This is basically
# performed by the private method {#find_file}. The config specified on command line (if any)
# is loaded the same way.
#
# == Command line:
# Any option can be declared as being callable from the command line. Modules add already some
# command line options, but the application can obviously add its own (see
# {EasyAppHelper::Core::Base#add_command_line_section}).
#
# Each of the config sources are kept in a separated "layer" and addressed this way using the
# #internal_configs attribute reader. But of course the config object provides a "merged" config
# result of the computation of all the sources. See the {#to_hash} method to see the order for the
# merge.
# Any option can be accessed or modified directly using the {#[]} and {#[]=} methods.
# Any change to the global config should be done using the {#[]=} method and is kept in the last separated
# layer called "modified". Therefore the config can be easily reset using the {#reset}
# method.
class EasyAppHelper::Core::Config < EasyAppHelper::Core::Base
end

require 'easy_app_helper/core/places'
require 'easy_app_helper/core/merge_policies'


class EasyAppHelper::Core::Config
  include EasyAppHelper::Core::HashesMergePolicies

  ADMIN_CONFIG_FILENAME = EasyAppHelper.name
  INTRODUCED_SORTED_LAYERS = [:specific_file, :user, :global, :internal, :system]

  # Potential extensions a config file can have
  CONFIG_FILE_POSSIBLE_EXTENSIONS = %w(conf yml cfg yaml CFG YML YAML Yaml)

  # @param [EasyAppHelper::Core::Logger] logger
  # The logger passed to this constructor should be a temporary logger until the full config is loaded.
  def initialize(logger)
    super
    add_cmd_line_options
    load_config
  end

  # After calling the super method, triggers a forced reload of the file based config.
  # @param [String] name of the config file
  # @see Base#script_filename=
  def script_filename=(name)
    super
    force_reload
  end

  # Sets the Application name and passes it to the logger.
  # @param [String] name
  # @see Base#app_name=
  def app_name=(name)
    super
    logger.progname = name
  end

  # Loads all config (command line and config files)
  # Do not reload a file if already loaded unless forced too.
  # It *does not flush the "modified" layer*. Use {#reset} instead
  # @param [Boolean] force to force the reload
  def load_config(force=false)
    super()
    load_layer_config :system, ADMIN_CONFIG_FILENAME, force
    load_layer_config :internal, script_filename, force
    load_layer_config :global, script_filename, force
    load_layer_config :user, script_filename, force
    load_layer_config :specific_file, internal_configs[:command_line][:content][:'config-file'], force
    self
  end

  # @see #load_config
  def force_reload
    load_config true
  end


  # This is the main method that provides the config as a hash.
  #
  # Every layer is kept untouched (and could accessed independently
  # using {#internal_configs}), while this methods provides a merged config.
  # @return [Hash] The hash of the merged config.
  def to_hash

    merged_config = {}

    # Process any other level as a low priority unmanaged layer
    internal_configs.keys.each do |layer|
      next if self.class.layers.include? layer
      hashes_second_level_merge merged_config, internal_configs[layer][:content]
    end

    # Process Config-level layers
    merged_config = [:system, :internal, :global, :user].inject(merged_config) do |temp_config, config_level|
      hashes_second_level_merge temp_config, internal_configs[config_level][:content]
    end
    if get_value :'config-file', :command_line
      if get_value :'config-override', :command_line
        override_merge merged_config, internal_configs[:specific_file][:content]
      else
        hashes_second_level_merge merged_config, internal_configs[:specific_file][:content]
      end

    end

    # Process Base-level layers with highest priority (last processed the highest)
    [:command_line, :modified].each { |base_layer|  hashes_second_level_merge merged_config, internal_configs[base_layer][:content]}
    merged_config

  end

  # @param [Object] key: The key to access the data in the merged_config hash (see {#to_hash})
  # @return [String] Value for this key in the merged config.
  def [](key = nil)
    key.nil? ? to_hash : to_hash[key]
  end


  # @return [String] The merged config (see {#to_hash}) rendered as Yaml
  def to_yaml
    to_hash.to_yaml
  end

  alias_method :to_s, :to_yaml
  alias_method :inspect, :internal_configs

  #############################################################################
  private

  # Command line options specific to config manipulation
  def add_cmd_line_options
    add_command_line_section('Configuration options') do |slop|
      slop.on 'config-file', 'Specify a config file.', :argument => true
      slop.on 'config-override', 'If specified override all other config.', :argument => false
    end
  end

  # Tries to find a config file to be loaded into the config layer cake unless cached.
  def load_layer_config(layer, filename_or_pattern, force=false)
    unless_cached(layer,  filename_or_pattern, force) do |layer, filename_or_pattern|
      fetch_config_layer layer, filename_or_pattern
    end
  end

  # Actual loads
  def fetch_config_layer(layer, filename_or_pattern)
    if filename_or_pattern.nil?
      internal_configs[layer] = {content: {}}
      filename = nil
    else
      if File.exists? filename_or_pattern and !File.directory? filename_or_pattern
        filename = filename_or_pattern
      else
        places = Places.possible_config_places[layer]
        filename = find_file places, filename_or_pattern
      end
      internal_configs[layer] = {content: load_config_file(filename, layer), source: filename, origin: filename_or_pattern}
    end
  ensure
    logger.info "No config file found for layer #{layer}." if filename.nil?
  end

  def unless_cached(layer, filename_or_pattern, forced)
    cached = false
    if internal_configs[layer]
      cached = true unless internal_configs[layer][:origin] == filename_or_pattern
    end
    if forced or not cached
      yield layer, filename_or_pattern
    end
  end

  # Tries to find config files according to places (array) given and possible extensions
  def find_file(places, filename)
    return nil if places.nil? or filename.nil? or filename.empty?
    places.each do |dir|
      CONFIG_FILE_POSSIBLE_EXTENSIONS.each do |ext|
        filename_with_path = dir + '/' + filename + '.' + ext
        if File.exists? filename_with_path and !File.directory? filename_with_path
          return filename_with_path 
        else
          logger.debug "Trying \"#{filename_with_path}\" as config file."
        end
      end
    end
    nil
  end

  def load_config_file(conf_filename, layer=nil)
    conf = {}
    return conf if conf_filename.nil?
    ext = layer.nil? ? '' : " as layer #{layer}"
    begin
      logger.debug "Loading config file \"#{conf_filename}\"#{ext}"
      conf = Hash[YAML::load(open(conf_filename)).map { |k, v| [k.to_sym, v] }]
    rescue => e
      logger.error "Invalid config file \"#{conf_filename}\"#{ext}. Skipped as not respecting YAML syntax!\n#{e.message}"
    end
    conf
  end

end
