#!/usr/bin/env ruby

require 'easy_app_helper'

# You can directly access the config or the logger through the EasyAppHelper module
puts "The application verbose flag is #{EasyAppHelper.config[:verbose]}"

# You can directly use the logger according to the command line flags
# This will do nothing unless --debug is set and --log-level is set to the correct level
EasyAppHelper.logger.info "Hi guys!"

# Fed up with the EasyAppHelper prefix ? Just include the module where you want
include EasyAppHelper

# You can override programmatically any part of the config
config[:debug] = true
logger.level = 1
config[:test] = 'Groovy'
EasyAppHelper.logger.info "Hi guys!... again"

# You can see the internals of the config
puts config.internal_configs.to_yaml
# Which will output
#:modified:
#  :content:
#    :log-level: 1
#    :debug: true
#    :test: cool
#  :source: Changed by code
#:command_line:
#  :content:
#    :auto:
#    :simulate:
#    :verbose: true
#    :help:
#    :config-file:
#    :config-override:
#    :debug:
#    :debug-on-err:
#    :log-level:
#    :log-file:
#  :source: Command line
#:system:
#  :content: {}
#  :source:
#  :origin: EasyAppHelper
#:global:
#  :content: {}
#  :source:
#  :origin: ''
#:user:
#  :content: {}
#  :source:
#  :origin: ''
#:specific_file:
#  :content: {}

# You see of course that the two modifications we did are in the modified sub-hash
# And now the merged config
puts config.to_hash

# But you can see the modified part as it is:
puts config.internal_configs[:modified]

# Of course you can access it from any class
class Dummy
  include EasyAppHelper

  def initialize
    puts "#{config[:test]} baby !"
    # Back to the original
    config.reset
    puts config.internal_configs[:modified]
  end
end

Dummy.new

# Some methods are provided to ease common tasks. For example this one will log at info level
# (so only displayed if debug mode and log level low enough), but will also puts on the console
# if verbose if set...
puts_and_logs "Hi world"
