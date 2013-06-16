#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

class EasyAppHelper::Core::Config < EasyAppHelper::Core::Base
end

require 'easy_app_helper/core/places'

class EasyAppHelper::Core::Config < EasyAppHelper::Core::Base
  ADMIN_CONFIG_FILENAME = EasyAppHelper.name

  # include paths specific to the OS
  include EasyAppHelper::Core::Config::Places.get_OS_module

  # Potential extensions a config file can have
  CONFIG_FILE_POSSIBLE_EXTENSIONS = ['conf', 'yml', 'cfg', 'yaml', 'CFG', 'YML', 'YAML', 'Yaml']


  def script_filename=(name)
    super
  end

  def add_cmd_line_options
    add_command_line_section('Configuration options') do |slop|
      slop.on 'config-file', 'Specify a config file.', :argument => true
    end
  end


  private


  # Tries to find config files according to places (array) given and possible extensions
  def find_file(places, filename)
    places.each do |dir|
      CONFIG_FILE_POSSIBLE_EXTENSIONS.each do |ext|
        filename_with_path = dir + '/' + filename + '.' + ext
        if File.exists? filename_with_path
          return filename_with_path
        else
          script_filename.logger.debug "Trying \"#{filename_with_path}\" as config file."
        end
      end
    end
    nil
  end
end


module EasyAppHelper::Core::Config::CommandLine

end

