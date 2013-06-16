#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'slop'

class EasyAppHelper::Core::Base

  attr_reader :script_filename, :app_name, :app_version, :app_description

  def initialize # (script_filename, app_name, app_description, app_version)
    build_default_command_line_options
    @script_filename = @app_name = @app_version = @app_description = ""
  end

  def help
    @slop_definition.to_s
  end

  def script_filename=(name)
    @script_filename = name
    @slop_definition.banner = build_banner
  end
  def app_name(name)
    @app_name = name
    @slop_definition.banner = build_banner
  end
  def app_version(version)
    @app_version = version
    @slop_definition.banner = build_banner
  end
  def app_description(description)
    @app_description = description
    @slop_definition.banner = build_banner
  end



  private

  # Builds common used command line options
  def build_default_command_line_options # (script_filename, app_name, app_description, app_version)
    # Default options
    @slop_definition = Slop.new do
      separator "-- Generic options -------------------------------------------"
      on :auto, 'Auto mode. Bypasses questions to user.', :argument => false
      on :simulate, 'Do not perform the actual underlying actions.', :argument => false
      on :v, :verbose, 'Enable verbose mode.', :argument => false
      on :h, :help, 'Displays this help.', :argument => false
    end
  end

  def build_banner
    "\nUsage: #{script_filename} [options]\n#{app_name} Version: #{app_version}\n\n#{app_description}"
  end

end