require 'fileutils'
require 'digest/sha1'

module EasyAppHelper
  module Scripts

    module Completion

      def deploy_zsh_completion_script(script, target)
        FileUtils.mkpath target
        puts <<EOM

------------------------------------------------------------------------------------------
INFORMATION:
    A new version of the zsh completion for '#{EasyAppHelper.config.app_name} #{EasyAppHelper.config.app_version}' has been installed.
    You may want to restart a terminal to take it account.
------------------------------------------------------------------------------------------

EOM
        FileUtils.copy script, target

      end

      def completion_script_changed?(script, target)
        script_name = File.basename script
        target_script = File.join target, script_name
        return true unless File.exists? target_script
        sha1_source = Digest::SHA1.hexdigest File.read script
        sha1_target = Digest::SHA1.hexdigest File.read target_script
        sha1_source != sha1_target
      end

      def install_or_update_completion(script, target)
        unless ENV['IGNORE_COMPLETION_UPDATE']
          if File.exists?(script)
            deploy_zsh_completion_script script, target if completion_script_changed? script, target
          end
        end
      end

    end

  end
end
