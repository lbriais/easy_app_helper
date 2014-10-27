# EasyAppHelper

 [![Build Status](https://travis-ci.org/lbriais/easy_app_helper.png?branch=master)](https://travis-ci.org/lbriais/easy_app_helper)
 [![Gem Version](https://badge.fury.io/rb/easy_app_helper.png)](http://badge.fury.io/rb/easy_app_helper)

**This [gem][EAP] aims at providing useful helpers for command line applications.**

This is a complete rewrite of the initial easy_app_helper gem. **It is not compatible with
apps designed for easy_app_helper prior to version 1.0.0**, although they could be very easily adapted
(anyway you always specify your gem dependencies using [semantic versioning](http://semver.org/) and the [pessimistic version operator]
(http://robots.thoughtbot.com/post/2508037841/rubys-pessimistic-operator), don't you ? More info [here](http://guides.rubygems.org/patterns/#declaring_dependencies)). Older applications should explicitly
require to use the latest version of the 0.x.x series instead. The config files themselves remain
compatible with all versions of **EasyAppHelper**, as they are actually just plain Yaml files...

The new **EasyAppHelper** module provides:

* A **super charged Config class** that:
 * Manages **multiple sources of configuration**(command line, multiple config files...) in a **layered config**.
 * Provides an **easy to customize merge mechanism** for the different **config layers** that renders a "live view"
   of the merged configuration, while keeping a way to access or modify independently any of them.
 * Allows **flexibility** when dealing with modification and provides a way to roll back modifications done to config
   anytime, fully reload it, blast it... Export feature could be very easily added and will probably.
* A **Logger tightly coupled with the Config** class, that will behave regarding options specified be it from
  command line or from any source(layer) of the config object...
* Embeds [Slop][slop] to handle **command line parameters** and keeps all parameters specified from the command
  line in a **dedicated layer of the config object**.
* A mechanism that ensures that as soon as you access any of the objects or methods exposed by EasyAppHelper,
  all of them are **fully configured and ready to be used**.

If you are writing command line applications, I hope you will like it because it's very easy to use,
and as unobtrusive as possible (you choose when you want to include or use as a module) while providing
a ready-for-prod config, logger and command line management.


Currently the only runtime dependency is the cool [Slop gem][slop] which is used to process the command line options.

[Why this gem][wiki] ?



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

Then can can immediately access the logger or the config objects. Here under a first example:

```ruby
require 'easy_app_helper'

# You can directly access the config or the logger through the **EasyAppHelper** module
puts "The application verbose flag is #{EasyAppHelper.config[:verbose]}"

# You can directly use the logger according to the command line flags
# This will do nothing unless --debug is set and --log-level is set to the correct level
EasyAppHelper.logger.info "Hi guys!"

# Fed up with the **EasyAppHelper** prefix ? Just include the module where you want
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
#:internal:
#  :content: {}
#  :source:
#  :origin: ''
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

# You see of course that the three modifications we did appear actually in the modified sub-hash
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


## Configuration layers

**EasyAppHelper** will look for files in numerous places. **Both Unix and Windows places are handled**.
All the files are [Yaml][yaml] files but could have names with different extensions.

You can look in the [classes documentation][doc] to know exactly which extensions and places the config
files are looked for.

### System config file

This config file is common to all applications that use EasyAppHelper. For example on a Unix system
regarding the rules described above, the framework will for the following files in that order:

```text
# It will be loaded in the :system layer
/etc/EasyAppHelper.conf
/etc/EasyAppHelper.yml
/etc/EasyAppHelper.cfg
/etc/EasyAppHelper.yaml
/etc/EasyAppHelper.CFG
/etc/EasyAppHelper.YML
/etc/EasyAppHelper.YAML
/etc/EasyAppHelper.Yaml
```

### Internal config file

This is an internal config file for the Gem itself. It will be located in the ```etc/``` or ```config/``` directory **inside** the Gem.
It is a way for a Gem to define a system default configuration.

```text
# The :internal layer
etc/myscript.conf
etc/myscript.yml
etc/myscript.cfg
etc/myscript.yaml
etc/myscript.CFG
etc/myscript.YML
etc/myscript.YAML
etc/myscript.Yaml
config/myscript.conf
config/myscript.yml
config/myscript.cfg
config/myscript.yaml
config/myscript.CFG
config/myscript.YML
config/myscript.YAML
config/myscript.Yaml
```


### Application config files

Application config file names are determined from the config.script_filename property. It initially contains
the bare name of the script(path and extension removed), but you can replace with whatever you want. Changing
this property causes actually the impacted files to be reloaded.

It is in fact a two level configuration. One is global (the :global layer) and the other is at user level (the
:user layer).

 For example on a Unix system or cygwin

```text
# For the :global layer
/etc/myscript.conf
/etc/myscript.yml 
/etc/myscript.cfg 
/etc/myscript.yaml
/etc/myscript.CFG 
/etc/myscript.YML 
/etc/myscript.YAML
/etc/myscript.Yaml
/usr/local/etc/myscript.conf
/usr/local/etc/myscript.yml
/usr/local/etc/myscript.cfg
/usr/local/etc/myscript.yaml
/usr/local/etc/myscript.CFG
/usr/local/etc/myscript.YML
/usr/local/etc/myscript.YAML
/usr/local/etc/myscript.Yaml
# For the :user level
${HOME}/.config/myscript.conf
${HOME}/.config/myscript.yml
${HOME}/.config/myscript.cfg
${HOME}/.config/myscript.yaml
${HOME}/.config/myscript.CFG
${HOME}/.config/myscript.YML
${HOME}/.config/myscript.YAML
${HOME}/.config/myscript.Yaml
```

### Command line specified config file

The command line option ```--config-file``` provides a way to specify explicitly a config file. On top of this the
option ```--config-override``` tells **EasyAppHelper** to ignore :system, :internal, :global and :user levels.

The file will be loaded in a separated layer called :specific_file


### The command line options

**EasyAppHelper** already provides by default some command line options. Imagine you have the following program.

```ruby
#!/usr/bin/env ruby

require 'easy_app_helper'

class MyApp
  include EasyAppHelper

  APP_NAME = "My super application"
  VERSION = '0.0.1'
  DESCRIPTION = 'This application is a proof of concept for EasyAppHelper.'


  def initialize
    # Providing this data is optional but brings better logging and online help
    config.describes_application(app_name: APP_NAME, app_version: VERSION, app_description: DESCRIPTION)
  end


  def run
    if config[:help]
      puts config.help
      exit 0
    end
    puts_and_logs "Application is starting"
    do_some_processing
  end

  def do_some_processing
    puts_and_logs "Starting some heavy processing"
  end

end


MyApp.new.run
```

And you run it without any command line option

```text
./test4_app.rb
```

No output...

Let' try

```text
./test4_app.rb --help

Usage: test4_app [options]
My super application Version: 0.0.1

This application is a proof of concept for EasyAppHelper.
-- Generic options -------------------------------------------------------------
        --auto                 Auto mode. Bypasses questions to user.
        --simulate             Do not perform the actual underlying actions.
    -v, --verbose              Enable verbose mode.
    -h, --help                 Displays this help.
-- Configuration options -------------------------------------------------------
        --config-file          Specify a config file.
        --config-override      If specified override all other config.
-- Debug and logging options ---------------------------------------------------
        --debug                Run in debug mode.
        --debug-on-err         Run in debug mode with output to stderr.
        --log-level            Log level from 0 to 5, default 2.
        --log-file             File to log to.

```
You see there the online help. And then the program exists.

Let's try the ```--verbose``` flag

```text
./test4_app.rb --verbose
Application is starting
Starting some heavy processing
```

You see that the puts_and_logs is sensitive to the ```--verbose``` switch...

But what if I debug
```text
./test4_app.rb --debug
```

Humm... nothing...  Let's provide the log level

```text
./test4_app.rb --debug --log-level 0
I, [2013-06-23T19:37:24.975392 #10276]  INFO -- My super application: Application is starting
I, [2013-06-23T19:37:24.975592 #10276]  INFO -- My super application: Starting some heavy processing
```

You see there that the puts_and_logs logs as well with the log level 1 (Info)... Nice looks like it was claiming
this in its name... ;-)

If I mix ?

```text
./test4_app.rb  --debug --log-level 0 --verbose
Application is starting
I, [2013-06-23T19:39:05.712558 #11768]  INFO -- My super application: Application is starting
Starting some heavy processing
I, [2013-06-23T19:39:05.712834 #11768]  INFO -- My super application: Starting some heavy processing
```

So far so good...

### Specifying command line parameters

As said, internally **EasyAppHelper** uses the [Slop gem][slop] to handle the command line parameters.
You can configure the internal Slop object by calling the add_command_line_section method of the config
object. You could create a method that setup your application command line parameters like this:

```ruby
  def add_cmd_line_options
    config.add_command_line_section do |slop|
      slop.on :u, :useless, 'Stupid option', :argument => false
      slop.on :anint, 'Stupid option with integer argument', :argument => true, :as => Integer
    end
  end

```

See [Slop gem][slop] API documentation for more options.


### Debugging the framework itself

If you want, you can even debug what happens during **EasyAppHelper** initialisation, for this you can use the
```DEBUG_EASY_MODULES``` environment variable. As how and where everything has to be logged is only specified when
you actually provide command line options, **EasyAppHelper** provides a temporary logger to itself and will
after all dump the logger content to the logger you specified and if you specify... So that you don't miss a log.

```text
$ DEBUG_EASY_MODULES=y ruby ./test4_app.rb

D, [2013-06-23T19:43:47.977031 #16294] DEBUG -- : Temporary initialisation logger created...
D, [2013-06-23T19:43:47.977861 #16294] DEBUG -- : Trying "/etc/EasyAppHelper.conf" as config file.
D, [2013-06-23T19:43:47.977908 #16294] DEBUG -- : Trying "/etc/EasyAppHelper.yml" as config file.
D, [2013-06-23T19:43:47.977938 #16294] DEBUG -- : Loading config file "/etc/EasyAppHelper.cfg"
D, [2013-06-23T19:43:47.978300 #16294] DEBUG -- : Trying "/etc/test4_app.conf" as config file.
D, [2013-06-23T19:43:47.978332 #16294] DEBUG -- : Trying "/etc/test4_app.yml" as config file.
D, [2013-06-23T19:43:47.978355 #16294] DEBUG -- : Trying "/etc/test4_app.cfg" as config file.
D, [2013-06-23T19:43:47.978381 #16294] DEBUG -- : Trying "/etc/test4_app.yaml" as config file.
D, [2013-06-23T19:43:47.978403 #16294] DEBUG -- : Trying "/etc/test4_app.CFG" as config file.
D, [2013-06-23T19:43:47.978424 #16294] DEBUG -- : Trying "/etc/test4_app.YML" as config file.
D, [2013-06-23T19:43:47.978445 #16294] DEBUG -- : Trying "/etc/test4_app.YAML" as config file.
D, [2013-06-23T19:43:47.978466 #16294] DEBUG -- : Trying "/etc/test4_app.Yaml" as config file.
D, [2013-06-23T19:43:47.978491 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.conf" as config file.
D, [2013-06-23T19:43:47.978529 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.yml" as config file.
D, [2013-06-23T19:43:47.978553 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.cfg" as config file.
D, [2013-06-23T19:43:47.978575 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.yaml" as config file.
D, [2013-06-23T19:43:47.978597 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.CFG" as config file.
D, [2013-06-23T19:43:47.978619 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.YML" as config file.
D, [2013-06-23T19:43:47.978670 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.Yaml" as config file.
I, [2013-06-23T19:43:47.978695 #16294]  INFO -- : No config file found for layer global.
D, [2013-06-23T19:43:47.978725 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.conf" as config file.
D, [2013-06-23T19:43:47.978748 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.yml" as config file.
D, [2013-06-23T19:43:47.978770 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.cfg" as config file.
D, [2013-06-23T19:43:47.978792 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.yaml" as config file.
D, [2013-06-23T19:43:47.978817 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.CFG" as config file.
D, [2013-06-23T19:43:47.978840 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.YML" as config file.
D, [2013-06-23T19:43:47.978861 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.YAML" as config file.
D, [2013-06-23T19:43:47.978974 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.Yaml" as config file.
I, [2013-06-23T19:43:47.979000 #16294]  INFO -- : No config file found for layer user.
I, [2013-06-23T19:43:47.979025 #16294]  INFO -- : No config file found for layer specific_file.
D, [2013-06-23T19:43:47.979514 #16294] DEBUG -- : Trying "/etc/EasyAppHelper.conf" as config file.
D, [2013-06-23T19:43:47.979561 #16294] DEBUG -- : Trying "/etc/EasyAppHelper.yml" as config file.
D, [2013-06-23T19:43:47.979591 #16294] DEBUG -- : Loading config file "/etc/EasyAppHelper.cfg"
D, [2013-06-23T19:43:47.979717 #16294] DEBUG -- : Trying "/etc/test4_app.conf" as config file.
D, [2013-06-23T19:43:47.979747 #16294] DEBUG -- : Trying "/etc/test4_app.yml" as config file.
D, [2013-06-23T19:43:47.979800 #16294] DEBUG -- : Trying "/etc/test4_app.cfg" as config file.
D, [2013-06-23T19:43:47.979823 #16294] DEBUG -- : Trying "/etc/test4_app.yaml" as config file.
D, [2013-06-23T19:43:47.979845 #16294] DEBUG -- : Trying "/etc/test4_app.CFG" as config file.
D, [2013-06-23T19:43:47.979867 #16294] DEBUG -- : Trying "/etc/test4_app.YML" as config file.
D, [2013-06-23T19:43:47.979908 #16294] DEBUG -- : Trying "/etc/test4_app.YAML" as config file.
D, [2013-06-23T19:43:47.979935 #16294] DEBUG -- : Trying "/etc/test4_app.Yaml" as config file.
D, [2013-06-23T19:43:47.979959 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.conf" as config file.
D, [2013-06-23T19:43:47.979981 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.yml" as config file.
D, [2013-06-23T19:43:47.980004 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.cfg" as config file.
D, [2013-06-23T19:43:47.980026 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.yaml" as config file.
D, [2013-06-23T19:43:47.980047 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.CFG" as config file.
D, [2013-06-23T19:43:47.980069 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.YML" as config file.
D, [2013-06-23T19:43:47.980091 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.YAML" as config file.
D, [2013-06-23T19:43:47.980112 #16294] DEBUG -- : Trying "/usr/local/etc/test4_app.Yaml" as config file.
I, [2013-06-23T19:43:47.980135 #16294]  INFO -- : No config file found for layer global.
D, [2013-06-23T19:43:47.980181 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.conf" as config file.
D, [2013-06-23T19:43:47.980207 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.yml" as config file.
D, [2013-06-23T19:43:47.980230 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.cfg" as config file.
D, [2013-06-23T19:43:47.980252 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.yaml" as config file.
D, [2013-06-23T19:43:47.980274 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.CFG" as config file.
D, [2013-06-23T19:43:47.980296 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.YML" as config file.
D, [2013-06-23T19:43:47.980319 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.YAML" as config file.
D, [2013-06-23T19:43:47.980361 #16294] DEBUG -- : Trying "/home/laurent/.config/test4_app.Yaml" as config file.
I, [2013-06-23T19:43:47.980395 #16294]  INFO -- : No config file found for layer user.
I, [2013-06-23T19:43:47.980418 #16294]  INFO -- : No config file found for layer specific_file.
D, [2013-06-23T19:43:47.981934 #16294] DEBUG -- : Config layers:
---
:modified:
  :content: {}
  :source: Changed by code
:command_line:
  :content:
    :auto:
    :simulate:
    :verbose: true
    :help:
    :config-file:
    :config-override:
    :debug: true
    :debug-on-err:
    :log-level: 0
    :log-file:
  :source: Command line
:system:
  :content:
    :copyright: (c) 2012-2013 Nanonet
  :source: /etc/EasyAppHelper.cfg
  :origin: EasyAppHelper
:internal:
  :content: {}
  :source:
  :origin: test4_app
:global:
  :content: {}
  :source:
  :origin: test4_app
:user:
  :content: {}
  :source:
  :origin: test4_app
:specific_file:
  :content: {}

D, [2013-06-23T19:43:47.985357 #16294] DEBUG -- : Merged config:
---
:copyright: (c) 2012-2013 Nanonet
:verbose: true
:debug: true
:log-level: 0

Application is starting
I, [2013-06-23T19:43:47.986298 #16294]  INFO -- My super application: Application is starting
Starting some heavy processing
I, [2013-06-23T19:43:47.986460 #16294]  INFO -- My super application: Starting some heavy processing
```

You can notice that what **EasyAppHelper** initialisation logged and what you application logged
did eventually end-up in the same log...


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


That's all folks.


[EAP]: https://rubygems.org/gems/easy_app_helper        "EasyAppHelper gem"
[slop]: https://rubygems.org/gems/slop        "Slop gem"
[yaml]: http://www.yaml.org/    "The Yaml official site"
[doc]: http://rubydoc.info/github/lbriais/easy_app_helper/master        "EasyAppHelper documentation"
[wiki]: https://github.com/lbriais/easy_app_helper/wiki          "EasyAppHelper wiki"