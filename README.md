# EasyAppHelper

**This [gem][EAP] aims at providing useful helpers for command line applications.**

This is a complete rewrite of the initial easy_app_helper gem. **It is not compatible with
apps designed for easy_app_helper prior to version 1.0.0**, although they could be very easily adapted.
But anyway you always specify your gem dependencies using the [pessimistic version operator]
(http://docs.rubygems.org/read/chapter/16#page74), don't you ? Older applications should do it to tell your application
to use the latest version of the 0.x.x series instead.

The new **EasyAppHelper** module prodides:

* A **super charged  Config class** that:
 * Manages **multiple sources of configuration**(command line, multiple config files...) in a **layered config**.
 * Provides an **easy to customize merge mechanism** for the different **config layers** that exposes a "live view"
   of the merged configuration, while keeping a way to access or modify independently any of them.
 * Allows **flexibility** when dealing with modification and provides a way to roll back modifications done to config
   anytime, fully reload it, blast it... Export feature could be very easily added and will probably.
* A **Logger tightly coupled with the Config** class, that will behave correctly regarding options specified be it from
  command line or from any source of the config object...
* Embeds [Slop][slop] to handle **command line parameters** and keeps any parameter defined in a **separated layer of
  the global config object**.
* A mechanism that ensures that as soon as you access any of the objects or methods exposed by EasyAppHelper,
  all of them are **fully configured and ready to be used**.
  
If you are writing command line applications, I hope you will like because it's very easy to use, and as unobtrusive as
possible (you choose when you want to include or use as a module) while providing a ready-for-prod config, logger
and command line management.


Currently the only runtime dependency is the cool [Slop gem][slop] which is used to process the command line options.

[Why this gem][4] ?

## Installation

Add this line to your application's Gemfile:

    gem 'easy_app_helper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_app_helper

## Usage

To use it, once you installed them, you just need to require it:

```ruby
require 'easy_app_helper'
```

Then can can immediately acces the logger or the config ojbects. Here under a first example:

```ruby
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

# It is actually one of the few methods added to regular Logger class (The added value of this logger
# is much more to be tightly coupled with the config object). Thus could access it like that:
logger.puts_and_logs "Hi world"

# or even
EasyAppHelper.logger.puts_and_logs "Hi world... 3 is enough."
```


## Config files

EasyAppHelper will look for files in numerous places. Both Unix and Windows places are handled.
All the files are Yaml files but could have names with different extensions.

You can look in the classes documentation to know exactly which extensions and places the config
files are looked for.

### System config file

This config file is common to all applications that use EasyAppHelper. For example on a Unix system
regarding the rules described above, the framework will for the following files in that order:


    /etc/EasyAppHelper.conf
    /etc/EasyAppHelper.yml
    /etc/EasyAppHelper.cfg
    /etc/EasyAppHelper.yaml
    /etc/EasyAppHelper.CFG
    /etc/EasyAppHelper.YML
    /etc/EasyAppHelper.YAML
    /etc/EasyAppHelper.Yaml

### Application config files

An application config file names are determined from the config.script_filename property. This initially contains
the bare name of the script, but you can replace with whatever you want. Changing this property causes actually
the impacted files to be reloaded.

It is in fact a two level configuration. One is global (the :global layer) and the other is at user level (the
:user layer).

 For example on a Unix setting







You can actually access any field from your application configuration through the app_config attribute.

### Other modules
Some other modules are provided:

* EasyAppHelper::Logger	provides logging facilities and config line options including log-level, log-file etc...
* EasyAppHelper::Config provides easy YAML based configuration to your script with multiple level of override (admin wide -> system wide -> user -> command line options -> --config-file). All the configuration being accessible through the app_config hash attribute

See [classes documentation] [3] for more information.

### Complete example

Here under a more complete (still useless) example using all the modules.

```ruby
require 'easy_app_helper'

class MyApp
  include EasyAppHelper
  include EasyAppHelper::Config
  include EasyAppHelper::Logger

  def initialize
    init_app_helper "my_app", "My Super Application", "This is the application everybody was waiting for.", "1.0"
    logger.info "Application is now started."
    show_config if app_config[:verbose]
  end

  def show_config
    puts "Application config is"
    puts app_config.to_yaml
  end

  def add_specifc_command_line_options(opt)
    opt.on :s, :stupid, 'This is a very stupid option', :argument => false
  end
end

app = MyApp.new
```

With this example you can already test some of the behaviours brought to the application by the different modules.

		 $ ruby ./test_app.rb

Nothing displayed... hum in fact normal.

*The EasyAppHelper::Base module*

		 $ ruby ./test_app.rb --verbose
		 Application config is
		 ---
		 :verbose: true
		 :log-level: 2

Here again we see the impact of the --verbose

		 $ ruby ./test_app.rb --help

		 Usage: my_app [options]
		 My Super Application Version: 1.0

		 This is the application everybody was waiting for.
		 -- Generic options -------------------------------------------
        			--auto              Auto mode. Bypasses questions to user.
        			--simulate          Do not perform the actual underlying actions.
    			-v, --verbose           Enable verbose mode.
				  -h, --help              Displays this help.

		 -- Debug and logging options ---------------------------------
        			--debug             Run in debug mode.
        			--debug-on-err      Run in debug mode with output to stderr.
        			--log-level         Log level from 0 to 5, default 2.
        			--log-file          File to log to.

		 -- Configuration options -------------------------------------
        			--config-file       Specify a config file.

		 -- Script specific options------------------------------------
     			-s, --stupid            This is a very stupid option


Here we see that:

* each included module added its own part in the global help
* The information passed to init_app_helper has been used in order to build a consistent help.
* The method implemented add_specifc_command_line_options did add the --stupid command line option and that it fits within the global help. the syntax is the [Slop] [slop] syntax, and many other options are available. See the [Slop] [slop] for further info.

*The EasyAppHelper::Debug module*

Now let's try some options related to the EasyAppHelper::Logger module

		 $ ruby ./test_app.rb --debug

Nothing is displayed. Why ? We used the logger.info stuff !! Just because the default log-level is 2 (Logger::Severity::WARN), whereas we did a info (Logger::Severity::INFO equals to 1).
Thus we can do a:

		 $ ruby ./test_app.rb --debug --log-level 1
		 I, [2013-03-20T10:58:40.819096 #13172]  INFO -- : Application is now started.

Which correctly displays the log.
Of course, as mentioned by the inline doc, this could go to a log file using the --log-file option...

*The EasyAppHelper::Config module*

From what we did, nothing really shows what the config module brought to the application, whereas in fact this is the one bringing the more features...

This module will try to find config files (YAML format) in different places. All the config files could have a lot of different extensions (EasyAppHelper::Config::Instanciator::CONFIG_FILE_POSSIBLE_EXTENSIONS). Here under we will just say ".ext", but all of them are tried:

First it will try to find the file:

			/etc/EasyAppHelper.ext

In this file you could define some options common to all the scripts you will build on top of EasyAppHelper helpers.

Then it will try to find (it will stop on the first found):

		 /etc/my_app.ext
		 /usr/local/etc/my_app.ext

In this file you could define some options common to all users

Then it will try to find:

		 ${HOME}/.config/my_app.conf

Where each user will generally store his own configuration.

Each of these file adds options to the common app_config hash. Enabling a simple and powerful override mechanism.

Then everything defined on the command line will itself override what has been defined in these config files.
Then if --config-file option is specified in the command line, it tries to load that file.

Thus in the end following mechanism:

		 admin wide -> system wide -> user -> command line options -> --config-file


### Debugging the framework itself

If you want to debug what happens during the framework instanciation, you can use the DEBUG_EASY_MODULES environment variable.

ex:

		 $ DEBUG_EASY_MODULES=y ruby ./test_app.rb
		 D, [2013-03-20T13:14:32.149109 #10564] DEBUG -- : Processing helper module: EasyAppHelper::Logger::Instanciator
		 D, [2013-03-20T13:14:32.149109 #10564] DEBUG -- : Processing helper module: EasyAppHelper::Config::Instanciator
		 D, [2013-03-20T13:14:32.149109 #10564] DEBUG -- : Trying "/etc/EasyAppHelper.conf" as config file.
		 D, [2013-03-20T13:14:32.149109 #10564] DEBUG -- : Trying "/etc/EasyAppHelper.yml" as config file.
		 D, [2013-03-20T13:14:32.149109 #10564] DEBUG -- : Trying "/etc/EasyAppHelper.cfg" as config file.
		 D, [2013-03-20T13:14:32.149109 #10564] DEBUG -- : Trying "/etc/EasyAppHelper.yaml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/EasyAppHelper.CFG" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/EasyAppHelper.YML" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/EasyAppHelper.YAML" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/EasyAppHelper.Yaml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/my_app.conf" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/my_app.yml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/my_app.cfg" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/my_app.yaml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/my_app.CFG" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/my_app.YML" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/my_app.YAML" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/etc/my_app.Yaml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/usr/local/etc/my_app.conf" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/usr/local/etc/my_app.yml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/usr/local/etc/my_app.cfg" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/usr/local/etc/my_app.yaml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/usr/local/etc/my_app.CFG" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/usr/local/etc/my_app.YML" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/usr/local/etc/my_app.YAML" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/usr/local/etc/my_app.Yaml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/home/user_home_dir/.config/my_app.conf" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/home/user_home_dir/.config/my_app.yml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/home/user_home_dir/.config/my_app.cfg" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/home/user_home_dir/.config/my_app.yaml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/home/user_home_dir/.config/my_app.CFG" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/home/user_home_dir/.config/my_app.YML" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/home/user_home_dir/.config/my_app.YAML" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Trying "/home/user_home_dir/.config/my_app.Yaml" as config file.
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Processing helper module: EasyAppHelper::Base::Instanciator
		 D, [2013-03-20T13:14:32.164733 #10564] DEBUG -- : Processing helper module: EasyAppHelper::Common::Instanciator

You can observe that for each of the included module, the framework uses its related so-called instanciator in order to know how to start the module, externalizing the methods into a separated module to avoid poluting your own application with methods useless for you when you include the module.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Creating your own EasyAppHelper module

You need to write two modules

* One EasyAppHelper::MyModule that will provide the features mixed in your application.
* One EasyAppHelper::MyModule::Instanciator that will extend (not include) EasyAppHelper::Common::Instanciator and that will be responsible to initialize your module.

That's all folks.


[EAP]: https://rubygems.org/gems/easy_app_helper        "EasyAppHelper gem"
[slop]: https://rubygems.org/gems/slop        "Slop gem"
[3]: http://rubydoc.info/github/lbriais/easy_app_helper/master/frames        "EasyAppHelper documentation"
[4]: https://github.com/lbriais/easy_app_helper/wiki          "EasyAppHelper wiki"